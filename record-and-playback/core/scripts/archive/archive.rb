# Set encoding to utf-8
# encoding: UTF-8
#
# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
#
# Copyright (c) 2017 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation; either version 3.0 of the License, or (at your option)
# any later version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
#


require '../lib/recordandplayback'
require 'logger'
require 'trollop'
require 'yaml'


def archive_events(meeting_id, redis_host, redis_port, raw_archive_dir, break_timestamp)
  BigBlueButton.logger.info("Archiving events for #{meeting_id}")
  #begin
    redis = BigBlueButton::RedisWrapper.new(redis_host, redis_port)
    events_archiver = BigBlueButton::RedisEventsArchiver.new redis    
    events = events_archiver.store_events(meeting_id,
                          "#{raw_archive_dir}/#{meeting_id}/events.xml",
                          break_timestamp)
  #rescue => e
  #  BigBlueButton.logger.warn("Failed to archive events for #{meeting_id}. " + e.to_s)
  #end
end

def archive_audio(meeting_id, audio_dir, raw_archive_dir)
  BigBlueButton.logger.info("Archiving audio #{audio_dir}/#{meeting_id}-*.wav")
  audio_dest_dir = "#{raw_archive_dir}/#{meeting_id}/audio"
  FileUtils.mkdir_p(audio_dest_dir)
  audio_files = Dir.glob("#{audio_dir}/#{meeting_id}-*.wav")
  if audio_files.empty?
    BigBlueButton.logger.warn("No audio found for #{meeting_id}")
    return
  end
  ret = BigBlueButton.exec_ret('rsync', '-rstv', *audio_files,
          "#{raw_archive_dir}/#{meeting_id}/audio/")
  if ret != 0
    BigBlueButton.logger.warn("Failed to archive audio for #{meeting_id}")
  end
end

def archive_directory(source, dest)
  BigBlueButton.logger.info("Archiving contents of #{source}")
  FileUtils.mkdir_p(dest)
  ret = BigBlueButton.exec_ret('rsync', '-rstv',
          "#{source}/", "#{dest}/")
  if ret != 0
    BigBlueButton.logger.warn("Failed to archive contents of #{source}")
  end
end

<<<<<<< HEAD
def archive_has_recording_marks?(meeting_id, raw_archive_dir, break_timestamp)
  doc = Nokogiri::XML(File.open("#{raw_archive_dir}/#{meeting_id}/events.xml"))

  # Find the start and stop timestamps for the current recording segment
  start_timestamp = BigBlueButton::Events.get_segment_start_timestamp(
          doc, break_timestamp)
  end_timestamp = BigBlueButton::Events.get_segment_end_timestamp(
          doc, break_timestamp)
  BigBlueButton.logger.info("Segment start: #{start_timestamp}, end: #{end_timestamp}")

  BigBlueButton.logger.info("Checking for recording marks for #{meeting_id} segment #{break_timestamp}")
  rec_events = BigBlueButton::Events.match_start_and_stop_rec_events(
          BigBlueButton::Events.get_start_and_stop_rec_events(doc, true))
  has_recording_marks = false
  # Scan for a set of recording start/stop events which fits any of these cases:
  # - Recording started during segment
  # - Recording stopped during segment
  # - Recording started before segment and stopped after segment
  rec_events.each do |rec_event|
    if (rec_event[:start_timestamp] > start_timestamp and
        rec_event[:start_timestamp] < end_timestamp) or
       (rec_event[:stop_timestamp] > start_timestamp and
        rec_event[:stop_timestamp] < end_timestamp) or
       (rec_event[:start_timestamp] <= start_timestamp and
        rec_event[:stop_timestamp] >= end_timestamp)
      has_recording_marks = true
    end
  end
  BigBlueButton.logger.info("Recording marks found: #{has_recording_marks}")
  has_recording_marks
=======
def archive_kurento_screenshare(meeting_id, screenshare_dir, raw_archive_dir)
  BigBlueButton.logger.info("Archiving WebRTC screenshare for #{meeting_id}.")
  begin
    deskshare_dest_dir = "#{raw_archive_dir}/#{meeting_id}/deskshare"
    FileUtils.mkdir_p(deskshare_dest_dir)
    Dir.glob("#{screenshare_dir}/#{meeting_id}/*").each do |file|
      BigBlueButton.logger.debug("#{file} to #{deskshare_dest_dir}")
      FileUtils.cp(file, deskshare_dest_dir)
    end
  end
end

def archive_presentation(meeting_id, presentation_dir, raw_archive_dir)
  BigBlueButton.logger.info("Archiving presentation for #{meeting_id}.")
  begin
    presentation_dest_dir = "#{raw_archive_dir}/#{meeting_id}/presentation"
    FileUtils.mkdir_p presentation_dest_dir
    BigBlueButton::PresentationArchiver.archive(meeting_id, "#{presentation_dir}/#{meeting_id}/#{meeting_id}", presentation_dest_dir)
  rescue => e
    BigBlueButton.logger.warn("Failed to archive presentations for #{meeting_id}. " + e.to_s)
  end
end

def archive_has_recording_marks?(meeting_id, raw_archive_dir)
  BigBlueButton.logger.info("Fetching the recording marks for #{meeting_id}.")

  # No recording events at all
  record_events = BigBlueButton::Events.get_record_status_events("#{raw_archive_dir}/#{meeting_id}/events.xml")
  BigBlueButton.logger.info("record_events:\n#{BigBlueButton.hash_to_str(record_events)}")
  if record_events.empty?
    return false
  end

  # Recorded section of meeting has 0 length
  duration = BigBlueButton::Events.get_recording_length("#{raw_archive_dir}/#{meeting_id}/events.xml")
  BigBlueButton.logger.info("record duration: #{duration}")
  if duration == 0
    return false
  end

  # There's recording events, process it
  return true
>>>>>>> upstream/v2.0.x-release
end


################## START ################################

opts = Trollop::options do
  opt :meeting_id, "Meeting id to archive", type: :string
  opt :break_timestamp, "Chapter break end timestamp", type: :integer
end
Trollop::die :meeting_id, "must be provided" if opts[:meeting_id].nil?

meeting_id = opts[:meeting_id]
break_timestamp = opts[:break_timestamp]

# This script lives in scripts/archive/steps while bigbluebutton.yml lives in scripts/
props = YAML::load(File.open('bigbluebutton.yml'))

audio_dir = props['raw_audio_src']
recording_dir = props['recording_dir']
raw_archive_dir = "#{recording_dir}/raw"
deskshare_dir = props['raw_deskshare_src']
screenshare_dir = props['raw_screenshare_src']
redis_host = props['redis_host']
redis_port = props['redis_port']
presentation_dir = props['raw_presentation_src']
video_dir = props['raw_video_src']
kurento_video_dir = props['kurento_video_src']
kurento_screenshare_dir = props['kurento_screenshare_src']
log_dir = props['log_dir']

# Determine the filenames for the done and fail files
if !break_timestamp.nil?
  done_base = "#{meeting_id}-#{break_timestamp}"
else
  done_base = meeting_id
end
archive_done_file = "#{recording_dir}/status/archived/#{done_base}.done"
archive_norecord_file = "#{recording_dir}/status/archived/#{done_base}.norecord"

BigBlueButton.logger = Logger.new("#{log_dir}/archive-#{meeting_id}.log", 'daily' )

target_dir = "#{raw_archive_dir}/#{meeting_id}"
<<<<<<< HEAD
FileUtils.mkdir_p target_dir
archive_events(meeting_id, redis_host, redis_port, raw_archive_dir, break_timestamp)
archive_audio(meeting_id, audio_dir, raw_archive_dir)
archive_directory("#{presentation_dir}/#{meeting_id}/#{meeting_id}",
                  "#{target_dir}/presentation")
archive_directory("#{screenshare_dir}/#{meeting_id}",
                  "#{target_dir}/deskshare")
archive_directory("#{video_dir}/#{meeting_id}",
                  "#{target_dir}/video/#{meeting_id}")

if not archive_has_recording_marks?(meeting_id, raw_archive_dir, break_timestamp)
  BigBlueButton.logger.info("There's no recording marks for #{meeting_id}, not processing recording.")

  if break_timestamp.nil?
    # we need to delete the keys here because the sanity phase might not
=======
if not FileTest.directory?(target_dir)
  FileUtils.mkdir_p target_dir
  archive_events(meeting_id, redis_host, redis_port, raw_archive_dir)
  archive_audio(meeting_id, audio_dir, raw_archive_dir)
  archive_presentation(meeting_id, presentation_dir, raw_archive_dir)
  archive_deskshare(meeting_id, deskshare_dir, raw_archive_dir)
  archive_screenshare(meeting_id, screenshare_dir, raw_archive_dir)
  archive_kurento_screenshare(meeting_id, kurento_screenshare_dir, raw_archive_dir)
  archive_video(meeting_id, video_dir, raw_archive_dir)
  archive_video(meeting_id, kurento_video_dir, raw_archive_dir)

  if not archive_has_recording_marks?(meeting_id, raw_archive_dir)
    BigBlueButton.logger.info("There's no recording marks for #{meeting_id}, not processing recording.")

    # we need to delete the keys here because the sanity phase won't
>>>>>>> upstream/v2.0.x-release
    # automatically happen for this recording
    BigBlueButton.logger.info("Deleting redis keys")
    redis = BigBlueButton::RedisWrapper.new(redis_host, redis_port)
    events_archiver = BigBlueButton::RedisEventsArchiver.new(redis)
    events_archiver.delete_events(meeting_id)
  end

  File.open(archive_norecord_file, "w") do |archive_norecord|
    archive_norecord.write("Archived #{meeting_id} (no recording marks")
  end

else
  File.open(archive_done_file, "w") do |archive_done|
    archive_done.write("Archived #{meeting_id}")
  end
end
