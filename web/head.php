<?php

echo "<!DOCTYPE html>\n";
echo "<html>\n";
echo "<head>\n";

include 'style.php';

echo "</head>\n";
echo "<body>\n";


echo "<ul>\n";
echo "  <li><a class=\"active\" href=\"home.php\">Home</a></li>\n";
echo "  <li><a class=\"active\" href=\"UploadPage.php\">Upload</a></li>\n";
echo "  <li class=\"dropdown\">\n";
echo "    <a href=\"#\" class=\"dropbtn\">Account Options</a>\n";
echo "    <div class=\"dropdown-content\">\n";
echo "      <a href=\"ChangePasswordPage.php\">Change Password</a>\n";
echo "    </div>\n";
echo "  </li>\n";
if ($isAdministrator == 1) {

    echo "    <li class=\"dropdown\">\n";
    echo "    <a href=\"#\" class=\"dropbtn\">Administrator Actions</a>\n";
    echo "    <div class=\"dropdown-content\">\n";
    echo "      <a href=\"AdminActionPage.php\">User and IP Management</a>\n";
    echo "      <a href=\"sessionsPage.php\">Sessions</a>\n";
    echo "    </div>\n";
    echo "   </li>\n";
        
    echo "    <li class=\"dropdown\">\n";
    echo "    <a href=\"#\" class=\"dropbtn\">Information</a>\n";
    echo "    <div class=\"dropdown-content\">\n";
    echo "      <a href=\"BlockedIPs.php\">List Blocked IPs</a>\n";
    echo "      <a href=\"BadLoginAttempts.php\">Bad Login Attempts</a>\n";
    echo "    </div>\n";
    echo "   </li>\n";

}

echo "    <li class=\"dropdown\">\n";
echo "    <a href=\"#\" class=\"dropbtn\">Docs</a>\n";
echo "    <div class=\"dropdown-content\">\n";
echo "    <a href=\"showLicense.php\">License</a>\n";
echo "    <a href=\"showAUP.php\">Acceptable Use Policy</a>\n";
echo "    </div>\n";
echo "   </li>\n";


echo "  <li><a href=\"logout.php\">Log Out</a></li>\n";
echo "  </li>\n";
echo "</ul>\n";

if (isset($_SESSION['ErrorMessage'])) {
	$ErrorMessage = $link->real_escape_string($_SESSION['ErrorMessage']);
	unset($_SESSION['ErrorMessage']);
	echo "<br><font color=\"red\">\n$ErrorMessage\n</font><br><br>\n";
	unset($ErrorMessage);
}
?>

