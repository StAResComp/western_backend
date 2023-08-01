<?php

declare(strict_types=1);

namespace WESTERN;

require_once 'autoload.php';

$message = '';

// map JSON fields to catch types in DB
$fields = ['numSmallCases' => 'neph_small',
	   'numMediumCases' => 'neph_med',
	   'numLargeCases' => 'neph_large',
	   'wtReturned' => 'neph_returned',
	   'numLobsterRetained' => 'lobs_retained',
	   'numLobsterReturned' => 'lobs_returned',
	   'numBrownRetained' => 'brown_retained',
	   'numBrownReturned' => 'brown_returned',
	   'numVelvetRetained' => 'velvet_retained',
	   'numVelvetReturned' => 'velvet_returned',
	   'numWrasseRetained' => 'wrasse_retained',
	   'numWrasseReturned' => 'wrasse_returned'];

// declare database object here
$db = NULL;

do {
    // get JSON input from POST
    if (!$input = file_get_contents('php://input')) {
	$message = 'missing input';
	break;
    }
    
    // make sure it is JSON
    if (!$json = json_decode($input)) {
	$message = 'not JSON input';
	break;
    }
    
    // check for JSON fields
    if (!isset($json->deviceId)) {
	$message = 'missing device ID';
	break;
    }
    
    if (!isset($json->catches) || 
	!is_array($json->catches) ||
	!count($json->catches)) {
	$message = 'catches is missing or not an array';
	break;
    }
    
    // start database transaction
    $db = DB::getInstance(true);
    
    // get ID from device string
    if (!$results = $db->deviceLogin($json->deviceId)) {
	$message = 'device ID not recognised';
	break;
    }
    
    $deviceID = (int) $results[0]->device_id;
    
    // loop over catches
    foreach ($json->catches as $c) {
	// check catch metadata fields
	if (!isset($c->lat) || !isset($c->lon) ||
	    !isset($c->stringNum) ||
	    !isset($c->timestamp)) {
	    $message = 'catch metadata missing';
	    break 2;
	}
	
	// add catch metadata and get catch ID back
	if (!$results = $db->addCatchMetadata($deviceID,
					      $c->stringNum,
					      (float) $c->lat,
					      (float) $c->lon,
					      $c->timestamp)) {
	    $message = 'problem adding catch metadata';
	    break 2;
	}
	
	$catchID = (int) $results[0]->new_catch_id;
	
	// check catch details
	foreach ($fields as $j => $d) {
	    if (isset($c->{$j})) {
		if (!$results = $db->addCatchDetail($catchID,
						    $d,
						    (float) $c->{$j})) {
		    $message = 'problem adding catch detail';
		    break 3;
		}
	    }
	}
    }
    
    // got here, so safe to commit transaction
    $db->commit();
} while (false);

// handle error
if ('' != $message) {
    http_response_code(400);
    
    if (NULL != $db) {
	$db->rollback();
    }
} else {
    $message = 'OK';
}

header('Content-type: application/json');
print json_encode(['message' => $message]);

?>
