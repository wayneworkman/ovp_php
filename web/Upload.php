<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
	include 'functions.php';
	include 'connect2db.php';

	if (!isset($_REQUEST['vTitle'])) {
		setMessage("Sorry, a video title is required.","UploadPage.php");
		die;
	} else {
		$vTitle = $link->real_escape_string(trim($_REQUEST['vTitle']));
		if ($vTitle == "") {
			setMessage("Sorry, a video title is required.","UploadPage.php");
			die;
		}
	}
	if (isset($_REQUEST['AcceptAUP'])) {
		$acceptAUP = $link->real_escape_string(trim($_REQUEST['AcceptAUP']));
		if ($acceptAUP != "Accepted") {
			setMessage("Sorry, you must accept the Acceptable Use Policy.","UploadPage.php");
			die;
		}
	} else {
		setMessage("Sorry, you must accept the Acceptable Use Policy.","UploadPage.php");
		die;
	}
	$target_dir = "$tempDir/";
	$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
	$uploadOk = 1;
	$fileType = pathinfo($target_file,PATHINFO_EXTENSION);
	$fileType = trim($fileType);
	//empty message variable for errors.
	$uploadMessage = "";

	// Check if file already exists. If so, delete it.
	if (file_exists($target_file)) {
		unlink($target_file);
	}

	define('KB', 1024);
	define('MB', 1048576);
	define('GB', 1073741824);
	define('TB', 1099511627776);

	// Check file size
	if ($_FILES["fileToUpload"]["size"] > 5*GB) {
		setMessage("Sorry, your file is too large. Limits are currently 5 GB.","UploadPage.php");
		die;
	}


	// Allow certain file formats
	if($fileType == "mp4" || $fileType == "webm" || $fileType == "ovg") {
		$uploadOk = 0;
		setMessage("Sorry, only mp4 and webm files are allowed.<br>You uploaded: $fileType","UploadPage.php");
		die;
	}


	if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
		// Process the file, background it.
		$command = "$processScript '$target_file' '$vTitle' '$UserID' &";
		shell_exec($command);
		setMessage("Upload successful. Your video should be available in a moment. Look for it in Home.","UploadPage.php");


	} else {
		setMessage("Sorry, there was an error uploading your file.","UploadPage.php");
		die;
	}
}
?>

