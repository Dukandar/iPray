
//
//  WebserviceUrl.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import Foundation
//let BASE_URL      =  "http://mobileappsdev.net/ipray/api/"       // Development Server
//let BASE_URL      =  "http://34.209.110.32/api/"  //staging Server version 1.1 & 1.2
//let BASE_URL      =  "http://34.209.110.32/dev/api-v2/"  //staging Server version 1.3, 1.4,1.5 & 1.5
//let BASE_URL      =  "http://174.129.132.9/"   // V2
let BASE_URL      =  "http://ipraysocialmedia.com/"   // V2

// Version 2
let ADOPTED_PRAYER_URl = BASE_URL + "prayer/myAdoptedPrayer"
let COPY_PRAYER_URl = BASE_URL + "prayer/myCopiedPrayer"

let CREATE_GROUP_URl = BASE_URL + "groups/createGroup"
let UPLOAD_GROUP_IMAGE_URl = BASE_URL + "Groups/uploadeGroupPicture"
let GET_ALL_GROUP_LIST = BASE_URL + "groups/getallgroups"
let GET_MY_GROUP_LIST = BASE_URL + "groups/getMyGroups"
let REQUEST_TO_JOIN_GROUP = BASE_URL + "groups/requestToJoinGroup"
let GET_GROUP_WALL_LIST_URL = BASE_URL + "prayer/prayerWall"
let GET_GROUP_BOOK_LIST_URL = BASE_URL + "prayer/prayerbook"
let ADD_GROUP_URL = BASE_URL + "prayer/addGroupPrayer"
let UPDATE_GROUP_URL = BASE_URL + "prayer/updateGroupPrayer"
let INVITE_TO_GROUP_URL = BASE_URL + "groups/inviteToJoinGroup"
let REMOVE_GROUP_PRAYER_URL = BASE_URL + "prayer/removePrayerFromGroup"
let ADOPT_GROUP_PRAYER_URL = BASE_URL + "prayer/prayerwall"
let COPY_GROUP_PRAYER_URL = BASE_URL + "prayer/copyGroupPrayer"
let PUBLISH_GROUP_PRAYER_URL = BASE_URL + "prayer/publishGroupPrayer"
let ANSWER_GROUP_PRAYER_URL = BASE_URL + "prayer/updateGroupPrayer"

let SAVE_GROUP_DETAIL_URL = BASE_URL + "groups/updateGroupInfo"
let UPDATE_GROUP_IMAGE_URl = BASE_URL + "Groups/uploadeGroupPicture"
let LEAVE_GROUP_URL = BASE_URL + "groups/removeFromGroup"
let UPDATE_COPYIED_PRAYER_REMINDER = BASE_URL + "prayer/setReminder"
// Version 1
let Login_URl = BASE_URL + "authentication/login"
let CREATE_ACCOUNT_URl = BASE_URL + "authentication/register"
let UPLOAD_PROFILE_IMAGE_URl = BASE_URL + "authentication/updateProfilepic"
let GET_USER_PRAYER_LIST_URL = BASE_URL + "prayer/myPrayer"
let GET_BUBBLES_LIST_URL = BASE_URL + "authentication/homeScreen"
let ADD_NEW_PRAYER_URL = BASE_URL + "prayer/addprayer"
let GET_USER_DETAIL_URL = BASE_URL + "authentication/getUserDetail"
let SAVE_USER_DETAIL_URL = BASE_URL + "authentication/updateProfile"
let GET_USER_CONTACT_URL = BASE_URL + "contact/getContact"
let SAVE_USER_CONTACT_URL = BASE_URL + "contact/uploadContact"
let SAVE_USER_NEW_CONTACT_URL = BASE_URL + "contact/insertContact"
let SAVE_USER_DELETE_CONTACT_URL = BASE_URL + "contact/deleteContact"
let REMOVE_PRAYER_URL = BASE_URL + "prayer/deleteMyPrayer"
let LOGIN_WITH_FACEBOOK = BASE_URL + "authentication/socialLogin"
let UPDATE_PRAYER = BASE_URL + "prayer/updatePrayer"
let LOGOUT_URL = BASE_URL + "authentication/logout"
let GET_SEARCH_RESULT_URL = BASE_URL + "prayer/searchUser"
let REMOVE_NOTIFICATION_PRAYER_URL = BASE_URL + "prayer/removePrayerRequest"
let GET_OTHER_USER_PRAYER_LIST_URL = BASE_URL + "prayer/myPrayerRequest"
let ANSWER_PRAYER_URL = BASE_URL + "prayer/setAnswered"
let START_PRAYER_URL = BASE_URL + "prayer/updateStatus"
let SHARE_PRAYER_URL = BASE_URL + "prayer/sharePrayer"
let UPDATE_TOKE_URL = BASE_URL + "authentication/updateToken"
let UPDATE_MOBILE_URl = BASE_URL + "authentication/updateMobile"
let CHECK_OTP_URl = BASE_URL + "authentication/verifyOtp"
let GET_FRIEND_PRAYER_LIST_URL = BASE_URL + "prayer/searchUserPrayer"
let FORGOT_PASSWORD_URl = BASE_URL + "authentication/forgetPassword"
let ALLREADY_SHARE_PRAYER_URL = BASE_URL + "prayer/alreadyShared"
let PAYMENT_STATUS_URL = BASE_URL + "authentication/subscriptionStatus"
let PAYMENT_SUBMIT_URL = BASE_URL + "authentication/subscriptionDetail"
let DELETE_REMINDER_URl = BASE_URL + "prayer/checkReminder"
let UPDATE_PRAYER_REMINDER = BASE_URL + "prayer/updateReminder"
let RESET_PASSWORD = BASE_URL + "authentication/changePassword"
let RESENT_OTP_URl = BASE_URL + "authentication/resendotp"
let DONATION_LIST_URl = BASE_URL + "authentication/subscriptionPlan"
let RESEND_PRAYER_URL = BASE_URL + "prayer/resendPrayer"

//VS 3.0
let GET_INVITETION_LIST = BASE_URL + "prayer/myInvitationList"
let ACCEPT_DECLINE_TAG_REQUEST = BASE_URL + "prayer/acceptTagInvitation"
let ADD_CONTACT = BASE_URL + "contact/addNewContact"
let TAG_PRAYER = BASE_URL + "prayer/tagUsers"
let PRAY_FOR_ALL = BASE_URL + "prayer/prayforAll"
let TAG_GROUP_PRAYER =  BASE_URL + "prayer/tagGroupPrayer"
let SEND_TAG_INVITATION_CODE =  BASE_URL + "prayer/tagPrayerByCode"
let VERIFY_TAG_INVITATION_CODE =  BASE_URL + "prayer/applyPrayerShareCode"

