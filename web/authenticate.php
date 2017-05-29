<?php
include 'vars.php';
include 'connect2db.php';
$REMOTE_ADDR = $link->real_escape_string($_SERVER ['REMOTE_ADDR']);
$sql = "SELECT BlockedIP FROM blockedIPs WHERE BlockedIP = '$REMOTE_ADDR' LIMIT 1";
$result = $link->query($sql);
if ($result->num_rows == 0) {
	$Username = $link->real_escape_string($_REQUEST['username']);
	$PlainPassword = $link->real_escape_string($_REQUEST['password']);
	$sql = "SELECT Password,UserEnabled FROM Users WHERE Username = '$Username' LIMIT 1";
	$result = $link->query($sql);
	$StoredPassword = "";
	if ($result->num_rows > 0) {
		// output data of each row
		while($row = $result->fetch_assoc()) {
        		$StoredPassword = $row["Password"];
			$UserEnabled = $row["UserEnabled"];
			//check the password.
			if (password_verify($PlainPassword, $StoredPassword) && $UserEnabled == "1") {
				session_start();
				$_SESSION['badLoginAttempt'] = "0";
				$_SESSION['ErrorMessage'] = "";
				$NewStoredPassword = password_hash("$PlainPassword", PASSWORD_DEFAULT);
				// First thing's first, update password hash.
				$sql = "UPDATE Users SET Password='$NewStoredPassword' WHERE Username = '$Username'";
				if ($link->query($sql)) {
					//password hash updated, create session token
					$bytes = openssl_random_pseudo_bytes(8, $cstrong);
					$REQUEST_TIME = $link->real_escape_string($_SERVER ['REQUEST_TIME']);
					// Get User's ID.
					$sql = "SELECT UserID FROM Users WHERE Username = '$Username' LIMIT 1";
					$result = $link->query($sql);
					while($row = $result->fetch_assoc()) {
                				$UserID = $row["UserID"];
					}
					if (isset($_SERVER["HTTP_USER_AGENT"])) {
						$HTTP_USER_AGENT = $link->real_escape_string($_SERVER ['HTTP_USER_AGENT']);
					} else {
						$HTTP_USER_AGENT = "No HTTP_USER_AGENT header set.";
    					}
					$Random_String = $link->real_escape_string(bin2hex($bytes));
					$RawFingerprint = $UserID . $REMOTE_ADDR . $HTTP_USER_AGENT . $Random_String;
                                	$fingerprint = password_hash("$RawFingerprint", PASSWORD_DEFAULT);
					$sql = "INSERT INTO Sessions (REQUEST_TIME,SessionUserID,REMOTE_ADDR,HTTP_USER_AGENT,Random_String,fingerprint) VALUES ('$REQUEST_TIME','$UserID','$REMOTE_ADDR','$HTTP_USER_AGENT','$Random_String','$fingerprint')";
					if ($link->query($sql)) {
						$_SESSION['fingerprint'] = $fingerprint;

						// All done, Send user along.
						unset($_SESSION['ErrorMessage']);
						unset($_SESSION['badLoginAttempt']);
						$NextURL=$home;
						header("Location: $NextURL");


					} else {
						// couldn't create session.
						die ($SiteErrorMessage);
					}
					$link->close();
				} else {
					// something went wrong with updating the password hash.
					$link->close();
					die ($SiteErrorMessage);
				}
			} else {
				// bad password or account is disabled.
				if (isset($_SERVER["HTTP_USER_AGENT"])) {
					$HTTP_USER_AGENT = $link->real_escape_string($_SERVER ['HTTP_USER_AGENT']);
				} else {
					$HTTP_USER_AGENT = "No HTTP_USER_AGENT header set.";
				}
				$REQUEST_TIME = $link->real_escape_string($_SERVER ['REQUEST_TIME']);
				$REMOTE_ADDR = $link->real_escape_string($_SERVER ['REMOTE_ADDR']);
				$sql = "INSERT INTO badLoginAttempts (badREQUEST_TIME,badUsername,badREMOTE_ADDR,badHTTP_USER_AGENT) VALUES ('$REQUEST_TIME','$Username','$REMOTE_ADDR','$HTTP_USER_AGENT')";
                        	if ($link->query($sql)) {$link->close();} else {$link->close();}
				//Bad login, send back to login screen - with an error.
				session_unset();
				session_start();
				$_SESSION['badLoginAttempt'] = "1";
				$_SESSION['ErrorMessage'] = $BadLoginError;
				$NextURL="login.php";
				header("Location: $NextURL");
				$link->close();
			}
		}
	} else {
		// bad username.
		if (isset($_SERVER["HTTP_USER_AGENT"])) {
			$HTTP_USER_AGENT = $link->real_escape_string($_SERVER ['HTTP_USER_AGENT']);
		} else {
			$HTTP_USER_AGENT = "No HTTP_USER_AGENT header set.";
		}
		$REQUEST_TIME = $link->real_escape_string($_SERVER ['REQUEST_TIME']);
		$REMOTE_ADDR = $link->real_escape_string($_SERVER ['REMOTE_ADDR']);
		$sql = "INSERT INTO badLoginAttempts (badREQUEST_TIME,badUsername,badREMOTE_ADDR,badHTTP_USER_AGENT) VALUES ('$REQUEST_TIME','$Username','$REMOTE_ADDR','$HTTP_USER_AGENT')";
		if ($link->query($sql)) {$link->close();} else {$link->close();}
		session_unset();
		session_start();
		$_SESSION['badLoginAttempt'] = "1";
		$_SESSION['ErrorMessage'] = $BadLoginError;
		$NextURL="login.php";
		header("Location: $NextURL");
	}
} else {
// IP is blocked.
session_unset();
session_start();
$_SESSION['badLoginAttempt'] = "1";
$_SESSION['ErrorMessage'] = $IPBlockedMessage;
$NextURL="login.php";
header("Location: $NextURL");
$link->close();
}
?>
