class_name SafeSave
extends RefCounted

## Staged ConfigFile writes. A failed commit never deletes the current save.
## Backup rotation happens only after the new file can be parsed and verified.
static func write_config(config: ConfigFile, path: String, validator: Callable = Callable()) -> Error:
	if validator.is_valid() and not validator.call(config):
		return ERR_INVALID_DATA
	var staging := path + ".tmp"
	var serialized := config.encode_to_text()
	var file := FileAccess.open(staging, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(serialized)
	file.flush()
	var err := file.get_error()
	file.close()
	if err != OK:
		return err
	var verified := ConfigFile.new()
	err = verified.load(staging)
	# Compare bytes, not a float parse/re-encode (which can normalize precision).
	if err != OK or FileAccess.get_sha256(staging) != serialized.sha256_text():
		DirAccess.remove_absolute(staging)
		return ERR_FILE_CORRUPT
	var previous := ConfigFile.new()
	if previous.load(path) == OK and (not validator.is_valid() or validator.call(previous)):
		err = previous.save(path + ".bak.tmp")
		if err == OK:
			err = DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak")
		if err != OK:
			DirAccess.remove_absolute(staging)
			return err
	err = DirAccess.rename_absolute(staging, path)
	if err != OK:
		DirAccess.remove_absolute(staging)
	return err

static func load_config(path: String, validator: Callable = Callable()) -> Dictionary:
	for candidate in [path, path + ".bak"]:
		var config := ConfigFile.new()
		if config.load(candidate) == OK:
			if not validator.is_valid() or validator.call(config):
				return {"config": config, "recovered": candidate != path, "error": OK}
	var existed := FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")
	return {"config": ConfigFile.new(), "recovered": false,
		"error": ERR_FILE_CORRUPT if existed else ERR_FILE_NOT_FOUND}
