import Auth from '/imports/ui/services/auth';
import Meetings from '/imports/api/meetings';
import { makeCall } from '/imports/ui/services/api';
// import KurentoBridge from '/imports/api/screenshare/client/bridge';

export default function () {
  window.addEventListener('message', function (e) {
    if (e.data === 'recToggle') {
      makeCall('toggleRecording');
      const recStart = !(Meetings.findOne({ meetingId: Auth._meetingID }).recordProp.recording);
      this.window.parent.postMessage({ response: recStart ? 'Start Recording' : 'Stop Recording' }, '*');
    } else if (e.data === 'srcShareToggle') {
      // KurentoBridge.kurentoShareScreen();
    }
  });
}
