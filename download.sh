#!/bin/bash

urlfile="/home/aaa/bbb/URLs To Download.txt"
downloadfolder="/home/aaaa/Music"
targetmusicfolder="/home/bbbb/Music/"
musicmoverbin="/home/aaaa/bbb/MusicMover/bin/Debug/net8.0/MusicMover.dll"
onetaggercli="/home/aaa/bbb/onetagger/target/release/onetagger-cli"

while IFS= read -r line; do
    [ -z "$line" ] && continue  # Skip blank lines
	
	#download using streamrip
    rip -q 2 url "$line"
	
    #cleanup, personally I don't want live music and the cover, comment if you want it
    find "$downloadfolder" -iname '*(live)*' -delete
    find "$downloadfolder" -iname 'cover.jpg' -delete
    find "$downloadfolder" -iname '*live from*' -delete
    find "$downloadfolder" -iname '*live at*' -delete
    #find "$downloadfolder" -type f -size +50M -delete
    find "$downloadfolder" -type d -empty -delete
  
    #tag
    $onetaggercli autotagger --path "$downloadfolder" -P deezer,musicbrainz --multiplatform --id3v24 --enable-shazam
  
    #rename the files, choose your own template or not
    $onetaggercli renamer \
    --path "$downloadfolder" \
    --template "%albumartist%/%album%/%albumartist% - %album% - %track% - %title%"
	
	#convert all the FLAC songs downloaded to M4A
	#just a personal preference
	find "$downloadfolder" -type f -name "*.flac"  | while read -r file; do
		# Check if the file exists before processing
		if [ ! -f "$file" ]; then
			echo "File not found: $file"
			continue
		fi

		# Generate the output m4a file name
		m4a_file="${file%.flac}.m4a"

		# Convert the flac file to m4a using ffmpeg, preserving metadata
		ffmpeg -hide_banner -y -vn -hwaccel auto -nostdin -i "$file" -c:a aac -b:a 320k -map_metadata 0 -map_metadata 0:s:0 "$m4a_file"

		# Check if ffmpeg succeeded
		if [ $? -eq 0 ]; then
			echo "Conversion succeeded for: $file"
			
			# Check the size of the original flac and the new m4a file
			original_size=$(stat -c%s "$file")
			new_size=$(stat -c%s "$m4a_file")

			# Convert sizes to MB (1 MB = 1,048,576 bytes)
			original_size_mb=$(echo "scale=2; $original_size / 1048576" | bc)
			new_size_mb=$(echo "scale=2; $new_size / 1048576" | bc)

			# Print out the original and new sizes in MB
			echo "Original FLAC size: $original_size_mb MB"
			echo "Converted MP3 size: $new_size_mb MB"

			# If the m4a file is smaller, replace the original flac file
			if [ "$new_size" -lt "$original_size" ]; then
				rm "$file"
				echo "FLAC file replaced with MP3: $m4a_file"
			else
				# If the m4a file is larger, delete the m4a file
				rm "$m4a_file"
				echo "No size improvement, MP3 file deleted: $m4a_file"
			fi
		else
			# If ffmpeg failed, report an error and remove the temporary file
			echo "Conversion failed for: $file"
			rm "$m4a_file"
		fi
	done
  
    #catergorize / move
    dotnet "$musicmoverbin" \
    --from "$downloadfolder" \
    --target "$targetmusicfolder" \
    --create-album-directory \
    --parallel \
    --delete-duplicate-from \
    --various-artists
	
    #cleanup (mostly error/corrupted files are deleted)
    rm -rf "$downloadfolder"
	
	sleep 5
done < "$urlfile"
