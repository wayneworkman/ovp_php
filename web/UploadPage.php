<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {

    include 'connect2db.php';
    include 'head.php';
    echo "<div>";
    echo "<br><br>";
    echo "<form action=\"Upload.php\" method=\"post\" enctype=\"multipart/form-data\">";
    echo "Video title:<br><input type=\"text\" name=\"vTitle\" id=\"vTitle\"><br><br>";
    echo "Select file to upload:<br>";
    echo "<input type=\"file\" name=\"fileToUpload\" id=\"fileToUpload\"><br><br>";
    echo "<input type=\"submit\" value=\"Upload\" name=\"submit\">";
    echo "</form>";
    echo "</div>";
    echo "</body>";
    echo "</html>";
}
?>

