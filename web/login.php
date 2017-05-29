<?php
include 'vars.php';
echo "<html>\n";
echo "<title>$SiteName</title>\n";
echo "<body>\n";
echo "<form name=\"login\" action=\"authenticate.php\" method=\"post\">\n";

session_start();
if (isset($_SESSION['badLoginAttempt'])) {
	if ( $_SESSION['badLoginAttempt'] == "1" ) {
		echo "<font color=\"red\">" . $_SESSION['ErrorMessage'] . "</font><br>";
	}
}

echo "username <input type=\"text\" name=\"username\">\n";
echo "<br>password <input type=\"password\" name=\"password\">\n";
echo "<br>\n";
echo "<input type=\"submit\" name=\"submit\" value=\"login\">\n";
echo "</form>\n";
echo "</body>\n";
echo "</html>\n";
?>
