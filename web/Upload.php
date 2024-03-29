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
	$target_dir = "$tempDir";
        
	$filename = basename($_FILES["fileToUpload"]["name"]);
        #Escape any unwanted characters.
        $filename = preg_replace("/[^a-zA-Z0-9.]/", "", $filename);
        $target_file = "$target_dir/$filename";

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
	//if($fileType != "mp4" && $fileType != "ovg" && $fileType != "webm") {
	//	setMessage("Sorry, only mp4,webm, and ovg files are allowed. You uploaded: $fileType","UploadPage.php");
	//	die;
	//}


	if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
		// Process the file, background it.
                $jobFile = fopen("$jobs/$filename.job", "w") or setMessage("Unable to write job file.");
                $txt = "file=\"$target_file\"\nvTitle=\"$vTitle\"\nuID=\"$UserID\"\n";
                fwrite($jobFile, $txt);
                fclose($jobFile);
		


                //$command = "$processScript '$target_file' '$vTitle' '$UserID' &";
		//shell_exec($command);
		setMessage("Your video will appear in Home after any necessary conversion.<br>To avoid waiting in the future, upload in mp4 format.","UploadPage.php");


	} else {
		setMessage("Sorry, there was an error uploading your file.","UploadPage.php");
		die;
	}
}
?>

