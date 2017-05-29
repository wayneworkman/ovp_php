<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
	if ($isAdministrator == 1) {
		include 'connect2db.php';
		include 'functions.php';


		//Function to do SQL query.
		function doQuery() {
			global $sql;
			global $link;
			global $SiteErrorMessage;
			global $NextURL;
			//echo "$sql<br>";
			if ($link->query($sql)) {
				// good, send back to NextURL
				$NextURL="AdminActionPage.php";
				header("Location: $NextURL");
			} else {
				// Error
				setMessage($SiteErrorMessage,"AdminActionPage.php");
			}
		}




		//Get data from form submission.
		$adminAction = $link->real_escape_string(trim($_REQUEST['adminAction']));
		$adminActionText = $link->real_escape_string(trim($_REQUEST['adminActionText']));
		

		$uID = $link->real_escape_string(trim($_REQUEST['uID']));


		//Strip spaces
		$adminActionText = str_replace(' ', '', $adminActionText);


		//If adminActionText is nothing, unset it.
		if ($adminActionText == "") {
			unset($adminActionText);
		}


		//if uID is nothing, unset it.
		if ($uID == "") {
			unset($uID);
		}

		//if gID is nothing, unset it.
		if ($gID == "") {
			unset($gID);
		}


		//Determine action and carry out action.
		switch ($adminAction) {

			case $AddNewUser:
				if (isset($adminActionText, $PasswordDefault)) {
					$NewPassword = password_hash($PasswordDefault, PASSWORD_DEFAULT);
					$sql = "INSERT INTO `Users` (`Username`,`Password`,`UserEnabled`) VALUES ('$adminActionText','$NewPassword','1')";
					doQuery();
				} else {
					setMessage($incomplete,"AdminActionPage.php");
				}
				break;

			case $DeleteSelectedUser:
				if (isset($uID)) {
					$sql = "DELETE FROM `UserGroupAssociation` WHERE `uID` = '$uID'";
					doQuery();
					$sql = "DELETE FROM `Sessions` WHERE `SessionUserID` = '$uID'";
					doQuery();
					$sql = "DELETE FROM `Users` WHERE `UserID` = '$uID'";
					doQuery();
				} else {
					setMessage($incomplete,"AdminActionPage.php");
                                }
				break;
			case $EnableSelectedUser:
				if (isset($uID)) {
					$sql = "UPDATE `Users` SET `UserEnabled` = '1' WHERE `UserID` = '$uID'";
					doQuery();
				} else {
                                        setMessage($incomplete,"AdminActionPage.php");
                                }
				break;
			case $DisableSelectedUser:
				if (isset($uID)) {
					$sql = "UPDATE `Users` SET `UserEnabled` = '0' WHERE `UserID` = '$uID'";
					doQuery();
				} else {
                                        setMessage($incomplete,"AdminActionPage.php");
                                }
				break;
			case $ResetSelectedUsersPassword:
				if (isset($uID)) {
					$NewPassword = password_hash($PasswordDefault, PASSWORD_DEFAULT);
					$sql = "UPDATE `Users` SET `Password` = '$NewPassword' WHERE `UserID` = $uID";
					doQuery();
				} else {
                                        setMessage($incomplete,"AdminActionPage.php");
                                }
				break;
			case $BlockIP:
				if (isset($adminActionText)) {
					$sql = "INSERT INTO `blockedIPs` (`BlockedIP`) VALUES ('$adminActionText')";
					doQuery();
				} else {
                                        setMessage($incomplete,"AdminActionPage.php");
                                }
				break;
			case $UnblockIP:
				if (isset($adminActionText)) {
					$sql = "DELETE FROM `blockedIPs` WHERE `BlockedIP` = '$adminActionText'";
					doQuery();
				} else {
                                        setMessage($incomplete,"AdminActionPage.php");
                                }
				break;
			default:
				setMessage($incomplete,"AdminActionPage.php");
		}







	} else {
		// not an admin, redirect to home.php
		$NextURL="home.php";
		header("Location: $NextURL");
	}
} else {
	$NextURL="login.php";
	header("Location: $NextURL");
}
$link->close();
?>

