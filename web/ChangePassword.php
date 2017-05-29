<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
	include 'connect2db.php';
	include 'functions.php';


	// Do actions here.
	$OldPassword = $link->real_escape_string(trim($_REQUEST['OldPassword']));
	$NewPassword = $link->real_escape_string(trim($_REQUEST['NewPassword']));
	
	if ($OldPassword == "" ) {
		unset($OldPassword);
	}
	if ($NewPassword == "" ) {
		unset($NewPassword);
	}

	if (isset($OldPassword, $NewPassword)) {


		$sql = "SELECT `Password` FROM `Users` WHERE `UserID` = '$UserID'";
		$result = $link->query($sql);
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$StoredPassword = trim($row["Password"]);
			}
		}
		if (password_verify($OldPassword, $StoredPassword)) {



			$NewPassword = password_hash($NewPassword, PASSWORD_DEFAULT);
			$sql = "UPDATE `Users` SET `Password` = '$NewPassword' WHERE `UserID` = $UserID";
			if ($link->query($sql)) {
				// good, send back to home.php
				$NextURL="home.php";
				header("Location: $NextURL");
			} else {
				// Error
				$link->close();
				setMessage($SiteErrorMessage,"ChangePasswordPage.php");
			}
		} else {
			//Mistyped password.
			$link->close();
			setMessage($BadLoginError,"ChangePasswordPage.php");
		}
	} else {
		setMessage($incomplete,"ChangePasswordPage.php");
	}
} else {
	$NextURL="login.php";
	header("Location: $NextURL");
}
?>

