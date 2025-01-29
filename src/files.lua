local files = {}
files.scriptPath = ""

function files.mkdir(name)
	os.execute(("mkdir %s"):format(name))
end

function files.copyDir(source, dest)
	os.execute(("cp -rf %s %s"):format(source, dest))
end

function files.copyFile(source, dest)
	os.execute(("cp %s %s"):format(source, dest))
end

function files.replaceWithGucci(file)
	os.execute(("sed -i 's/soundsphere/gucci!mania/g' %s"):format(file))
end

function files.createArchive(dir, destination)
	os.execute(("cd %s;zip -r %s ."):format(dir, ("%s/%s"):format(files.scriptPath, destination)))
end

return files
