<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
	include 'connect2db.php';
	include 'functions.php';
	if ($isAdministrator == 1) {

		if (isset($_REQUEST['ConfirmDelete'])) {
			$ConfirmDelete = $link->real_escape_string(trim($_REQUEST['ConfirmDelete']));
		}
		$years = $link->real_escape_string(trim($_REQUEST['years']));
		$thisMoment = time();

		if ((is_numeric($years)) && ($ConfirmDelete == "Confirmed")) {
			$timeDifference = ( $thisMoment - ($years * 31536000)); // 1 year in seconds is 31536000.

			$sql = "DELETE FROM `badLoginAttempts` WHERE `badREQUEST_TIME` <= '$timeDifference'";
			if ($link->query($sql)) {
				// good, send back to usernameTracking.
				$NextURL="BadLoginAttempts.php";
				header("Location: $NextURL");
			} else {
				// Error
				$link->close();
				setMessage($SiteErrorMessage,"BadLoginAttempts.php");
			}
		} else {
			$link->close();
			setMessage($invalidData,"BadLoginAttempts.php");
		}


	} else {
		//Not an admin, redirect to home.
		$NextURL="home.php";
		header("Location: $NextURL");
	}
}
?>

