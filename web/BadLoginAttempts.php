<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
	include 'connect2db.php';
	include 'head.php';
	if ($isAdministrator == 1) {
		echo "<title>Bad Login Attempts</title>";
		echo "<div>";
		//Recent bad login attempts.
		echo "<font color=\"red\">Bad login attempts</font><br><br>";

		$sql = "SELECT `badREQUEST_TIME`,`badUsername`,`badREMOTE_ADDR`,`badHTTP_USER_AGENT` FROM `badLoginAttempts` ORDER BY `badREQUEST_TIME` desc";
		$result = $link->query($sql);
		if ($result->num_rows > 0) {


			echo "<form action=\"clearBadLogins.php\" method=\"post\">\n";
			echo "Clear bad login attempts older than\n";
			echo " <input type=\"text\" name=\"years\" value=\"1\" style=\"width:20px;\"> years.<br>\n";
			echo "<input type=\"checkbox\" name=\"ConfirmDelete\" value=\"Confirmed\">Confirm Delete<br>\n";
			echo "<input type=\"submit\" value=\"Clear Bad Logins\">\n";
			echo "<br><br>\n";

			echo "<table>\n";
			echo "<tr>\n";
			echo "<th>Time</th>\n";
			echo "<th>Username</th>\n";
			echo "<th>Address</th>\n";
			echo "<th>Browser</th>\n";
			echo "</tr>\n";
			while($row = $result->fetch_assoc()) {
				$badTime = trim($row["badREQUEST_TIME"]);
				$badUsername = trim($row["badUsername"]);
				$badAddress = trim($row["badREMOTE_ADDR"]);
				$badBrowser = trim($row["badHTTP_USER_AGENT"]);
				$badTime = new DateTime("@$badTime");
				$badTime->setTimezone(new DateTimeZone("$TimeZone"));
				echo "<tr>\n";
				echo "<td>" . $badTime->format("F j, Y, g:i a") . "</td>\n";
				echo "<td>$badUsername</td>\n";
				echo "<td>$badAddress</td>\n";
				echo "<td>$badBrowser</td>\n";
				echo "</tr>\n";
			}
			echo "</table>\n";
			$result->free();
		}
		echo "</div>";
		echo "</body>";
		echo "</html";
	} else {
	//Not an admin, redirect to home.
	$NextURL="home.php";
	header("Location: $NextURL");
	}
}
?>


