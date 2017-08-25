<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'connect2db.php';
    include 'head.php';
    echo "<title>Welcome</title>";
    echo "<div>";
    include 'welcome';
    echo "</div>";
    echo "</body>";
    echo "</html>";
}
?>
