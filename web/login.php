<?php
include 'vars.php';
echo "<html>\n";
echo "<head>\n";
include 'style.php';
echo "</head>\n";
echo "<title>$SiteName</title>\n";
echo "<body>\n";
echo "<form name=\"login\" action=\"authenticate.php\" method=\"post\">\n";

session_start();
if (isset($_SESSION['badLoginAttempt'])) {
	if ( $_SESSION['badLoginAttempt'] == "1" ) {
		echo "<font color=\"red\">" . $_SESSION['ErrorMessage'] . "</font><br>";
	}
}

echo "username<br> <input type=\"text\" name=\"username\" style=\"width:600px;\">\n";
echo "<br>password<br> <input type=\"password\" name=\"password\" style=\"width:600px;\">\n";
echo "<br>\n";
echo "<input type=\"submit\" name=\"submit\" value=\"login\">\n";
echo "</form>\n";
echo "<br><br>\n";
echo "Request an account: $contactEmail";
echo "</body>\n";
echo "</html>\n";
?>
