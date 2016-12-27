<?php
 
$response = array();
 
$data = json_decode(file_get_contents('php://input'), true);

if ($data) {

    $myLat = $data['latitude'];
    $myLng = $data['longitude'];
    
    require_once __DIR__ . '/db_connect.php';

    $sectorIdQuery = mysql_query("SELECT id FROM sector WHERE $myLat<d1 and $myLat>a1 and $myLng<c2 and $myLng>d2");

	if(mysql_num_rows($sectorIdQuery) > 0) {

		$sectorId = mysql_fetch_object($sectorIdQuery);

		$sectorIdValue = $sectorId->id;

		$quests = mysql_query("SELECT * FROM quest WHERE sid=$sectorIdValue");

		if(mysql_num_rows($quests) > 0) {
			$response["message"] = "Quests successfully selected.";

			while($row = mysql_fetch_array($quests, MYSQL_ASSOC)) {
				$response[$row["pos"]]["lat"] = $row["lat"];
				$response[$row["pos"]]["lng"] = $row["lng"];
			}			
		}

	} else {
		$response["message"] = "Sector not found.";
	}    

    if (mysql_affected_rows() > 0) {
		$response["success"] = "true";
        mysql_query("COMMIT"); 
    } else {
        $response["success"] = "false";
    }    
    
} else {
    $response["success"] = "false";
    $response["message"] = "No JSON found.";
}

echo json_encode($response);
?>
