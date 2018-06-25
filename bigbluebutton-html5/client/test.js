import Auth from '/imports/ui/services/auth';
import Meetings from '/imports/api/meetings';
import { makeCall } from '/imports/ui/services/api';

export default function () {
  window.addEventListener('message', function (e) {
    if (e.data === 'c_record') {
      makeCall('toggleRecording');
      console.dir(Meetings.findOne({ meetingId: Auth._meetingID }).recordProp);
      // console.dir(Meetings.findOne({ meetingId: Auth.meetingID }).recordPro);
      this.window.parent.postMessage({ response: 'recording start/stop' }, '*');
    }
  });
}
