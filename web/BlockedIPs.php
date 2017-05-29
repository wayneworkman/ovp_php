<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'connect2db.php';
    include 'head.php';

    if ($isAdministrator == 1) {

        echo "<title>List Blocked IPs</title>";
        echo "<div>";
        echo "<form>";
        $sql = "SELECT `BlockedIP` FROM `blockedIPs`";
        $result = $link->query($sql);
        echo "List of blocked IPs:<br>";
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                echo "&emsp;&emsp;" . $row["BlockedIP"] . "<br>";
            }
            $result->free();
        }
        echo "</div>";
        echo "</body>";
        echo "</html";
    }
} else {
    //Not an admin, redirect to home.
    $NextURL="home.php";
    header("Location: $NextURL");
}
?>


