<?php

include 'vars.php';
$v = $_REQUEST['v'];
$file = pathinfo($v, PATHINFO_FILENAME);
$ext = pathinfo($v, PATHINFO_EXTENSION);
include 'connect2db.php';


#Check for blocked IPs.
$REMOTE_ADDR = $link->real_escape_string($_SERVER ['REMOTE_ADDR']);
$sql = "SELECT BlockedIP FROM blockedIPs WHERE BlockedIP = '$REMOTE_ADDR' LIMIT 1";
$result = $link->query($sql);
if ($result->num_rows == 0) {
    //Not blocked, display content.
    echo "<!DOCTYPE html>\n";
    echo "<html>\n";
    echo "<body>\n";
    echo "<video controls autoplay preload=\"auto\" src=\"stream.php?v=$v\" width=\"60%\"></video>\n";
    echo "<br><br>\n";
    echo "Request an account: $contactEmail";
    echo "</body>\n";
    echo "</html>\n";
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

