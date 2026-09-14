const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onValueCreated } = require('firebase-functions/v2/database');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

// ─────────────────────────────────────────────
// Function 1: New application → notify company
// ─────────────────────────────────────────────
exports.onNewApplication = onDocumentCreated(
  'applications/{applicationId}',
  async (event) => {
    const { applicationId } = event.params;
    const data = event.data.data();

    if (!data) {
      logger.warn(`No data for application ${applicationId}`);
      return;
    }

    const companyId = data.companyId;
    const applicantName = data.seekerName || 'Someone';
    const jobTitle = data.jobTitle || 'a position';

    if (!companyId) {
      logger.warn(`No companyId on application ${applicationId}`);
      return;
    }

    const jobId = data.jobId;
    if (jobId) {
      const jobDoc = await db.collection('jobs').doc(jobId).get();
      if (!jobDoc.exists) {
        logger.warn(`Job ${jobId} no longer exists, skipping notification`);
        return;
      }
    }

    // Write notification to Firestore unconditionally (in-app badge/list)
    try {
      await db
        .collection('notifications').doc(companyId).collection('items')
        .add({
          type: 'new_application',
          title: 'New Application Received 📋',
          body: `${applicantName} applied for ${jobTitle}`,
          applicationId,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      logger.info(`Notification document written for company ${companyId}`);
    } catch (err) {
      logger.error('Failed to write notification document', err);
    }

    // FCM push is best-effort — do not gate anything on it
    let fcmToken;
    try {
      const companyDoc = await db.collection('companies').doc(companyId).get();
      fcmToken = companyDoc.data()?.fcmToken;
    } catch (err) {
      logger.error(`Failed to read company doc for ${companyId}`, err);
      return;
    }

    if (!fcmToken) {
      logger.warn(`No FCM token for company ${companyId}`);
      return;
    }
    logger.info(`FCM token found for company ${companyId} (len=${fcmToken.length})`);

    const message = {
      data: {
        type: 'new_application',
        title: 'New Application Received 📋',
        body: `${applicantName} applied for ${jobTitle}`,
        applicationId,
      },
      token: fcmToken,
    };

    logger.info(`onNewApplication: FCM token for company ${companyId}: "${fcmToken}" (len=${fcmToken.length})`);
    try {
      const response = await admin.messaging().send(message);
      logger.info(`onNewApplication: FCM send SUCCESS to company ${companyId}, response: ${JSON.stringify(response)}`);
    } catch (err) {
      logger.error(`onNewApplication: FCM send FAILED for company ${companyId}: ${err.message} (code=${err.code})`);
    }
  },
);

// ─────────────────────────────────────────────
// Function 2: Application accepted → notify seeker
// ─────────────────────────────────────────────
exports.onApplicationAccepted = onDocumentUpdated(
  'applications/{applicationId}',
  async (event) => {
    const { applicationId } = event.params;
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!after) return;
    if (after.status !== 'Accepted') return;
    if (before && before.status === 'Accepted') return;

    const jobSeekerId = after.seekerId || after.jobSeekerId;
    const jobTitle = after.jobTitle || 'a position';

    if (!jobSeekerId) {
      logger.warn(`No jobSeekerId on application ${applicationId}`);
      return;
    }

    // Write notification to Firestore unconditionally
    try {
      await db
        .collection('notifications').doc(jobSeekerId).collection('items')
        .add({
          type: 'application_update',
          title: 'Application Accepted! 🎉',
          body: `Your application for ${jobTitle} has been accepted`,
          applicationId,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      logger.info(`Notification document written for job seeker ${jobSeekerId}`);
    } catch (err) {
      logger.error('Failed to write notification document', err);
    }

    // FCM push is best-effort
    let fcmToken;
    try {
      const seekerDoc = await db.collection('jobSeekers').doc(jobSeekerId).get();
      fcmToken = seekerDoc.data()?.fcmToken;
    } catch (err) {
      logger.error(`Failed to read jobSeeker doc for ${jobSeekerId}`, err);
      return;
    }

    if (!fcmToken) {
      logger.warn(`No FCM token for job seeker ${jobSeekerId}`);
      return;
    }

    const message = {
      data: {
        type: 'application_update',
        title: 'Application Accepted! 🎉',
        body: `Congratulations! Your application for ${jobTitle} has been accepted`,
        applicationId,
      },
      token: fcmToken,
    };

    logger.info(`onApplicationAccepted: FCM token for seeker ${jobSeekerId}: "${fcmToken}" (len=${fcmToken.length})`);
    try {
      const response = await admin.messaging().send(message);
      logger.info(`onApplicationAccepted: FCM send SUCCESS to seeker ${jobSeekerId}, response: ${JSON.stringify(response)}`);
    } catch (err) {
      logger.error(`onApplicationAccepted: FCM send FAILED for seeker ${jobSeekerId}: ${err.message} (code=${err.code})`);
    }
  },
);

// ─────────────────────────────────────────────
// Function 3: Application rejected → notify seeker
// ─────────────────────────────────────────────
exports.onApplicationRejected = onDocumentUpdated(
  'applications/{applicationId}',
  async (event) => {
    const { applicationId } = event.params;
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!after) return;
    if (after.status !== 'Rejected') return;
    if (before && before.status === 'Rejected') return;

    const jobSeekerId = after.seekerId || after.jobSeekerId;
    const jobTitle = after.jobTitle || 'a position';

    if (!jobSeekerId) {
      logger.warn(`No jobSeekerId on application ${applicationId}`);
      return;
    }

    // Write notification to Firestore unconditionally
    try {
      await db
        .collection('notifications').doc(jobSeekerId).collection('items')
        .add({
          type: 'application_update',
          title: 'Application Update',
          body: `Unfortunately, your application for ${jobTitle} was not accepted`,
          applicationId,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      logger.info(`Notification document written for job seeker ${jobSeekerId}`);
    } catch (err) {
      logger.error('Failed to write notification document', err);
    }

    // FCM push is best-effort
    let fcmToken;
    try {
      const seekerDoc = await db.collection('jobSeekers').doc(jobSeekerId).get();
      fcmToken = seekerDoc.data()?.fcmToken;
    } catch (err) {
      logger.error(`Failed to read jobSeeker doc for ${jobSeekerId}`, err);
      return;
    }

    if (!fcmToken) {
      logger.warn(`No FCM token for job seeker ${jobSeekerId}`);
      return;
    }

    const message = {
      data: {
        type: 'application_update',
        title: 'Application Update',
        body: `Unfortunately, your application for ${jobTitle} was not accepted`,
        applicationId,
      },
      token: fcmToken,
    };

    logger.info(`onApplicationRejected: FCM token for seeker ${jobSeekerId}: "${fcmToken}" (len=${fcmToken.length})`);
    try {
      const response = await admin.messaging().send(message);
      logger.info(`onApplicationRejected: FCM send SUCCESS to seeker ${jobSeekerId}, response: ${JSON.stringify(response)}`);
    } catch (err) {
      logger.error(`onApplicationRejected: FCM send FAILED for seeker ${jobSeekerId}: ${err.message} (code=${err.code})`);
    }
  },
);

// ─────────────────────────────────────────────
// Function 4: New chat message → notify recipient
// ─────────────────────────────────────────────
exports.onNewChatMessage = onValueCreated(
  'chats/{chatId}/messages/{pushId}',
  async (event) => {
    const { chatId } = event.params;
    const data = event.data.val();

    if (!data) return;

    const senderId = data.senderId;
    if (!senderId) return;

    let chatData;
    try {
      const chatSnapshot = await admin
        .database()
        .ref(`chats/${chatId}`)
        .once('value');
      chatData = chatSnapshot.val();
    } catch (err) {
      logger.error(`Failed to read chat ${chatId}`, err);
      return;
    }

    if (!chatData) {
      logger.warn(`Chat ${chatId} not found`);
      return;
    }

    const { companyId, seekerId, companyName, seekerName } = chatData;

    if (!companyId || !seekerId) {
      logger.warn(`Chat ${chatId} missing participant IDs`);
      return;
    }

    let receiverId;
    let senderDisplayName;
    let fcmToken;

    if (senderId === companyId) {
      receiverId = seekerId;
      senderDisplayName = companyName || 'Company';
      try {
        const seekerDoc = await db.collection('jobSeekers').doc(seekerId).get();
        fcmToken = seekerDoc.data()?.fcmToken;
      } catch (err) {
        logger.error(`Failed to read jobSeeker doc for ${seekerId}`, err);
      }
    } else if (senderId === seekerId) {
      receiverId = companyId;
      senderDisplayName = seekerName || 'Job Seeker';
      try {
        const companyDoc = await db.collection('companies').doc(companyId).get();
        fcmToken = companyDoc.data()?.fcmToken;
      } catch (err) {
        logger.error(`Failed to read company doc for ${companyId}`, err);
      }
    } else {
      logger.warn(
        `Sender ${senderId} is neither company nor seeker in chat ${chatId}`,
      );
      return;
    }

    if (senderId === receiverId) {
      logger.warn(`Sender and receiver are the same in chat ${chatId}, skipping`);
      return;
    }

    const messageText = data.text || '';
    if (!messageText) {
      logger.warn('Empty message text, skipping notification');
      return;
    }

    // FCM push is best-effort
    if (!fcmToken) {
      logger.warn(`No FCM token for receiver ${receiverId}`);
      return;
    }

    const message = {
      data: {
        type: 'chat_message',
        title: senderDisplayName,
        body: messageText,
        chatId,
        senderId,
      },
      token: fcmToken,
    };

    logger.info(`onNewChatMessage: FCM token for receiver ${receiverId}: "${fcmToken}" (len=${fcmToken.length})`);
    try {
      const response = await admin.messaging().send(message);
      logger.info(`onNewChatMessage: FCM send SUCCESS to receiver ${receiverId}, response: ${JSON.stringify(response)}`);
    } catch (err) {
      logger.error(`onNewChatMessage: FCM send FAILED for receiver ${receiverId}: ${err.message} (code=${err.code})`);
    }
  },
);
