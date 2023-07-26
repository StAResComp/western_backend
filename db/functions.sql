--
/*CREATE OR REPLACE FUNCTION  ( --{{{
)
RETURNS TABLE (
)
AS $FUNC$
BEGIN
  RETURN QUERY
;
END;
$FUNC$ LANGUAGE plpgsql SECURITY DEFINER VOLATILE;*/
--}}}

-- get device ID using device string
CREATE OR REPLACE FUNCTION deviceLogin ( --{{{
  in_device_string CHAR(16)
)
RETURNS TABLE (
  device_id INTEGER
)
AS $FUNC$
BEGIN
  RETURN QUERY
    SELECT d.device_id
      FROM devices AS d
     WHERE d.device_string = in_device_string;
END;
$FUNC$ LANGUAGE plpgsql SECURITY DEFINER STABLE;
--}}}

-- add metadata for catch, getting new catch ID
CREATE OR REPLACE FUNCTION addCatchMetadata ( --{{{
  in_device_id INTEGER,
  in_string_num TEXT,
  in_lat NUMERIC(15, 12),
  in_lon NUMERIC(15, 12),
  in_time_stamp TIMESTAMP WITHOUT TIME ZONE
)
RETURNS TABLE (
  new_catch_id INTEGER
)
AS $FUNC$
BEGIN
  RETURN QUERY
    INSERT INTO catch_md
                (device_id, string_num, lat, lon, time_stamp)
         VALUES (in_device_id, in_string_num, in_lat, in_lon, in_time_stamp)
      RETURNING catch_id;
END;
$FUNC$ LANGUAGE plpgsql SECURITY DEFINER VOLATILE;
--}}}

-- add catch detail
CREATE OR REPLACE FUNCTION addCatchDetail ( --{{{
  in_catch_id INTEGER,
  in_catch_type VARCHAR(16),
  in_quantity NUMERIC(7, 3)
)
RETURNS TABLE (
  out_catch_type_id INTEGER
)
AS $FUNC$
BEGIN
  RETURN QUERY
    INSERT INTO catch_details
                (catch_id, catch_type_id, quantity)
         SELECT in_catch_id, 
	        t.catch_type_id,
		in_quantity
           FROM catch_types AS t
	  WHERE t.catch_type = in_catch_type
      RETURNING catch_type_id;
END;
$FUNC$ LANGUAGE plpgsql SECURITY DEFINER VOLATILE;
--}}}
