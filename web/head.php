<?php

echo "<!DOCTYPE html>\n";
echo "<html>\n";
echo "<head>\n";

echo "<style>\n";
echo "ul {\n";
echo "    list-style-type: none;\n";
echo "    margin: 0;\n";
echo "    padding: 0;\n";
echo "    overflow: hidden;\n";
echo "    background-color: #333;\n";
echo "}\n";

echo "li {\n";
echo "    float: left;\n";
echo "}\n";

echo "li a, .dropbtn {\n";
echo "    display: inline-block;\n";
echo "    color: white;\n";
echo "    text-align: center;\n";
echo "    padding: 14px 16px;\n";
echo "    text-decoration: none;\n";
echo "}\n";

echo "li a:hover, .dropdown:hover .dropbtn {\n";
echo "    background-color: red;\n";
echo "}\n";

echo "li.dropdown {\n";
echo "    display: inline-block;\n";
echo "}\n";

echo ".dropdown-content {\n";
echo "    display: none;\n";
echo "    position: absolute;\n";
echo "    background-color: #f9f9f9;\n";
echo "    min-width: 160px;\n";
echo "    box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);\n";
echo "}\n";

echo ".dropdown-content a {\n";
echo "    color: black;\n";
echo "    padding: 12px 16px;\n";
echo "    text-decoration: none;\n";
echo "    display: block;\n";
echo "    text-align: left;\n";
echo "}\n";

echo ".dropdown-content a:hover {background-color: #f1f1f1}\n";

echo ".dropdown:hover .dropdown-content {\n";
echo "    display: block;\n";
echo "}\n";
echo "div{padding:10px;border:5px solid gray;margin:0}\n";
echo "<!--\n";
echo ".tab { margin-left: 40px; }\n";
echo "-->\n";
echo "table {\n";
echo "    font-family: arial, sans-serif;\n";
echo "    border-collapse: collapse;\n";
echo "    width: 100%;\n";
echo "}\n";

echo "td, th {\n";
echo "    border: 1px solid #dddddd;\n";
echo "    text-align: left;\n";
echo "    padding: 8px;\n";
echo "}\n";

echo "tr:nth-child(even) {\n";
echo "    background-color: #dddddd;\n";
echo "}\n";

echo "</style>\n";
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

