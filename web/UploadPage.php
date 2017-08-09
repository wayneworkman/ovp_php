<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {

    include 'connect2db.php';
    include 'head.php';
    echo "<div>\n";
    echo "<br><br>\n";
    echo "<form action=\"Upload.php\" method=\"post\" enctype=\"multipart/form-data\">\n";
    echo "Video title:<br><input type=\"text\" name=\"vTitle\" id=\"vTitle\" style=\"width:600px;\"><br><br>\n";
//    echo "Select file to upload (mp4, webm, and ovg only):<br>\n";
    echo "Select file to upload:<br>\n";
    echo "<input type=\"file\" name=\"fileToUpload\" id=\"fileToUpload\"><br><br>\n";
    echo "<input type=\"checkbox\" name=\"AcceptAUP\" value=\"Accepted\">I agree to and am abiding by the <a href=\"showAUP.php\">Acceptable Use Policy</a>.<br><br>\n";
    echo "<input type=\"submit\" value=\"Upload\" name=\"submit\">\n";
    echo "</form>\n";
    echo "</div>\n";
    echo "</body>\n";
    echo "</html>\n";
}
?>

