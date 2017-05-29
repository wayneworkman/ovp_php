<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'connect2db.php';
    include 'head.php';
    echo "<title>License</title>";
    echo "<div>";
    include 'LICENSE';
    echo "</div>";
    echo "</body>";
    echo "</html>";
}
?>
