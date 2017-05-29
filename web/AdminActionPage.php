<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'connect2db.php';
    include 'head.php';

    if ($isAdministrator == 1) {
        echo "<title>User and IP Management</title>";
        echo "<div>";
        echo "<form action=\"AdminAction.php\" method=\"post\">";
        echo "User and IP Management<br>";
        echo "<p class=\"tab\">";


        echo "Text for selected action:<br><input type=\"text\" name=\"adminActionText\"><br>";
        echo "<br>";


        $UserIDs = array();
        $UserNames = array();

        echo "<select name='uID'>";
        echo "<option value=''>Pick User</option>";
        $sql = "SELECT `Username`,`UserID` from `Users`";
        $result = $link->query($sql);
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                echo "<option value='" . trim($row['UserID']) . "'>" . trim($row['Username']) . "</option>";
                $UserIDs[] = trim($row['UserID']);
                $UserNames[] = trim($row['Username']);
            }
            $result->free();
        } else {
            echo "<option value='no_users'>no_users</option>";
        }
        echo "</select>";

        echo "<br>";

        $i = 0;
        foreach ($adminActionNames as $adminAction) {
            echo "<input type=\"radio\" name=\"adminAction\" value=\"$adminAction\">$adminAction<br>";
            $i = $i + 1;
        }

        echo "<br>";
        echo "<input type=\"submit\">";
        echo "</form>";
        echo "</div>";


        echo "</body>";
        echo "</html>";
    }
} else {
    //Not an admin, redirect to home.
    $NextURL="home.php";
    header("Location: $NextURL");
}
?>

