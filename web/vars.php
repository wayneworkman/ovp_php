<?php

// Database connect settings.
$servername = 'ovp.cu1wnaspvbot.us-east-2.rds.amazonaws.com';
$username = 'web';
$password = 'webpassword';
$database = 'ovp';



$domainName="perpetuum.io";

// Various site settings.
$SessionTimeout = 900; // measured in seconds.
$PasswordDefault = "changeme";
$SiteName = "Perpetuum";
$home = "home.php"; //This is the home file.
$tempDir = "/data/uploads";
$videoDir = "/data/videos";
$deleteDir = "/data/deleted";
$qrCodes = "/data/qrCodes";
$jobs = "/data/jobs";
$processScript = "/data/scripts/processUpload.sh";

$contactEmail = "wayne.workman2015@gmail.com";

// Messages. 
$SiteErrorMessage = "ERROR: There was a site problem. Report this to your administrator and try again later.";
$BadLoginError = "ERROR: Username and/or password is no good.";
$IPBlockedMessage = "ERROR: You are blocked.";
$incomplete = "ERROR: Not all fields completed.";
$invalidData = "ERROR: Invalid data in one or more fields.";



//Timezone info.
$TimeZone="America/Chicago";
//Find a listing of timezones here:
//  http://php.net/manual/en/timezones.php
date_default_timezone_set($TimeZone);




$adminActionNames = array();
$AddNewUser = "Add New User";
$adminActionNames[] = $AddNewUser;
$DeleteSelectedUser = "Delete Selected User";
$adminActionNames[] = $DeleteSelectedUser;
$EnableSelectedUser = "Enable Selected User";
$adminActionNames[] = $EnableSelectedUser;
$DisableSelectedUser = "Disable Selected User";
$adminActionNames[] = $DisableSelectedUser;
$ResetSelectedUsersPassword = "Reset Selected Users Password to $PasswordDefault";
$adminActionNames[] = $ResetSelectedUsersPassword;
$BlockIP = "Block IP";
$adminActionNames[] = $BlockIP;
$UnblockIP = "Unblock IP";
$adminActionNames[] = $UnblockIP;




?>

