/**
 * @classdesc
 * Model class for external devices
 */

'use strict'

const C = require('../constants/Constants');
const SdpWrapper = require('../utils/SdpWrapper');
const rid = require('readable-id');
const MediaServer = require('../media/media-server');
const MediaSession = require('./MediaSession');
const config = require('config');
const kurentoUrl = config.get('kurentoUrl');
const Logger = require('../../../utils/Logger');

module.exports = class SdpSession extends MediaSession {
  constructor(emitter, sdp = null, room, type = 'WebRtcEndpoint', options) {
    super(emitter, room, type, options);
    Logger.info("[mcs-sdp-session] New session with options", options);
    // {SdpWrapper} SdpWrapper
    this._sdp;
    if (sdp && type) {
      this.setSdp(sdp, type);
    }
  }

  async setSdp (sdp, type) {
    this._sdp = new SdpWrapper(sdp, type);
    await this._sdp.processSdp();
  }

  async process () {
    try {
      const answer = await this._MediaServer.processOffer(this._mediaElement, this._sdp.getPlainSdp());

      if (this._type === 'WebRtcEndpoint') {
        this._MediaServer.gatherCandidates(this._mediaElement);
      }

      return Promise.resolve(answer);
    }
    catch (err) {
      err = this._handleError(err);
      return Promise.reject(err);
    }
  }

  async addIceCandidate (candidate) {
    try {
      await this._MediaServer.addIceCandidate(this._mediaElement, candidate);
      Promise.resolve();
    }
    catch (err) {
      err = this._handleError(err);
      Promise.reject(err);
    }
  }
}
