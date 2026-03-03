module mutagen.track;

import std.conv;
import std.stdio : File;
import std.file;
import std.path : extension, dirName;
import std.string;
import std.variant;

import mutagen.format.flac;
import mutagen.format.mp3;
import mutagen.format.mp4;
import mutagen.album;
import mutagen.image;

class Track
{
public:
    File file;
    Variant data;
    Album album;
    string name;
    int number;

    this(File audioFile)
    {
        this.file = audioFile;

        switch (extension(audioFile.name).toLower())
        {
            case ".flac":
                data = new FLAC(audioFile);
                break;
            case ".mp3":
                data = new MP3(audioFile);
                break;
            case ".m4a":
            case ".mp4":
            case ".aac":
                data = new MP4(audioFile);
                break;
            default:
                break;
        }

        file.close();

        // Extract metadata
        string[] title = this["TITLE"];
        if (title.length > 0)
            this.name = title[0];

        string[] trackNum = this["TRACKNUMBER"];
        if (trackNum.length > 0)
        {
            string str = trackNum[0];
            ptrdiff_t slash = str.indexOf('/');
            if (slash > 0)
                str = str[0..slash];
            
            str = str.strip();
            if (str.length > 0)
            {
                try
                    this.number = str.to!int;
                catch (Exception) { }
            }
        }
    }

    static Track fromFile(string path, Album album = null)
    {
        File file = File(path, "rb");
        Track ret = new Track(file);
        ret.album = album;
        return ret;
    }

    string[] opIndex(string str) const
    {
        if (data.type == typeid(FLAC))
            return data.get!FLAC[str];
        else if (data.type == typeid(MP3))
            return data.get!MP3[str];
        else if (data.type == typeid(MP4))
            return data.get!MP4[str];

        return null;
    }

    string opIndexAssign(string val, string tag)
    {
        if (data.type == typeid(FLAC))
            return data.get!FLAC[tag] = val;
        else if (data.type == typeid(MP3))
            return data.get!MP3[tag] = val;
        else if (data.type == typeid(MP4))
            return data.get!MP4[tag] = val;

        return val;
    }

    Image image()
    {
        Image img;
        if (data.type == typeid(FLAC))
            img = data.get!FLAC.image;
        else if (data.type == typeid(MP3))
            img = data.get!MP3.image;
        else if (data.type == typeid(MP4))
            img = data.get!MP4.image;

        if (img.hasData())
            return img;

        string dir = dirName(file.name);
        if (!exists(dir) || !isDir(dir))
            return img;

        try
        {
            foreach (entry; dirEntries(dir, SpanMode.shallow))
            {
                if (!entry.isFile)
                    continue;

                string ext = extension(entry.name).toLower();
                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
                    return Image.fromData(cast(ubyte[])read(entry.name));
            }
        }
        catch (Exception) { }

        return img;
    }

    int getPlayCount()
    {
        if (!data.hasValue)
            return 0;

        string[] tags = this["PLAY_COUNT"];
        if (tags is null)
            tags = this["PCNT"];
        
        if (tags is null || tags.length == 0)
            return 0;

        try
            return tags[0].strip().to!int;
        catch (Exception)
            return 0;
    }

    bool setPlayCount(int count)
    {
        if (!data.hasValue)
            return false;

        string str = count.to!string;
        if (this["PCNT"] != null)
            this["PCNT"] = str;
        else
            this["PLAY_COUNT"] = str;
        return true;
    }
}
