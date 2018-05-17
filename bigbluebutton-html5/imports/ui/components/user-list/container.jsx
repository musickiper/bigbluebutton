import React from 'react';
import PropTypes from 'prop-types';
import { withTracker } from 'meteor/react-meteor-data';
import { meetingIsBreakout } from '/imports/ui/components/app/service';
import Meetings from '/imports/api/meetings';
import Service from './service';
import UserList from './component';

const propTypes = {
  openChats: PropTypes.arrayOf(String).isRequired,
  users: PropTypes.arrayOf(Object).isRequired,
  currentUser: PropTypes.shape({}).isRequired,
  meeting: PropTypes.shape({}).isRequired,
  isBreakoutRoom: PropTypes.bool.isRequired,
  getAvailableActions: PropTypes.func.isRequired,
  normalizeEmojiName: PropTypes.func.isRequired,
  isMeetingLocked: PropTypes.func.isRequired,
  isPublicChat: PropTypes.func.isRequired,
  setEmojiStatus: PropTypes.func.isRequired,
  assignPresenter: PropTypes.func.isRequired,
  removeUser: PropTypes.func.isRequired,
  toggleVoice: PropTypes.func.isRequired,
  changeRole: PropTypes.func.isRequired,
  roving: PropTypes.func.isRequired,
};

const UserListContainer = (props) => {
  const {
    users,
    currentUser,
    openChats,
    isBreakoutRoom,
    meeting,
    getAvailableActions,
    normalizeEmojiName,
    isMeetingLocked,
    isPublicChat,
    setEmojiStatus,
    assignPresenter,
    removeUser,
    toggleVoice,
    changeRole,
    roving,
    CustomLogoUrl,
  } = props;

  return (
    <UserList
      {...{
        users,
        currentUser,
        openChats,
        isBreakoutRoom,
        meeting,
        getAvailableActions,
        normalizeEmojiName,
        isMeetingLocked,
        isPublicChat,
        setEmojiStatus,
        assignPresenter,
        removeUser,
        toggleVoice,
        changeRole,
        roving,
        CustomLogoUrl,
      }
    }
    />
  );
};

UserListContainer.propTypes = propTypes;

export default withTracker(({ params }) => ({
  users: Service.getUsers(),
  meeting: Meetings.findOne({}),
  currentUser: Service.getCurrentUser(),
  openChats: Service.getOpenChats(params.chatID),
  isBreakoutRoom: meetingIsBreakout(),
  getAvailableActions: Service.getAvailableActions,
  normalizeEmojiName: Service.normalizeEmojiName,
  isMeetingLocked: Service.isMeetingLocked,
  isPublicChat: Service.isPublicChat,
  setEmojiStatus: Service.setEmojiStatus,
  assignPresenter: Service.assignPresenter,
  removeUser: Service.removeUser,
  toggleVoice: Service.toggleVoice,
  changeRole: Service.changeRole,
  roving: Service.roving,
  CustomLogoUrl: Service.getCustomLogoUrl(),
}))(UserListContainer);
