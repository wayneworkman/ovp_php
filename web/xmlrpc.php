<?php

// This is an auto-blocking file for anyone that tries to access it.
// Requesting xmlrpc.php is an attack by malacious persons.


//Function to do SQL query.
function doQuery() {
    global $sql;
    global $link;
    global $SiteErrorMessage;
    global $NextURL;
    //echo "$sql<br>";
    if ($link->query($sql)) {
        // good, send back to NextURL
        $NextURL="login.php";
        header("Location: $NextURL");
    } else {
        // Error
        setMessage($SiteErrorMessage,"AdminActionPage.php");
    }
}



include 'vars.php';
include 'connect2db.php';
$REMOTE_ADDR = $link->real_escape_string($_SERVER ['REMOTE_ADDR']);
$sql = "SELECT BlockedIP FROM blockedIPs WHERE BlockedIP = '$REMOTE_ADDR' LIMIT 1";
$result = $link->query($sql);
if ($result->num_rows == 0) {
    //If not already blocked, block it.
    $sql = "INSERT INTO `blockedIPs` (`BlockedIP`) VALUES ('$REMOTE_ADDR')";
    doQuery();
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
