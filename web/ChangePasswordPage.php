<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'connect2db.php';
    include 'head.php';
    echo "<title>Change Password</title>";
    echo "<div>";
    echo "<form action=\"ChangePassword.php\" method=\"post\">";
    echo "Change Password<br>";
    echo "<p class=\"tab\">";
    echo "Old Password:<br><input type=\"password\" name=\"OldPassword\" autocomplete=\"off\"><br>";
    echo "New Password:<br><input type=\"password\" name=\"NewPassword\" autocomplete=\"off\"><br>";
    echo "<br>";
    echo "<input type=\"submit\">";
    echo "</form>";
    echo "</div>";
    echo "</body>";
    echo "</html>";
}
?>

