module mutagen.album;

import std.algorithm : sort;

import mutagen.artist;
import mutagen.image;
import mutagen.track;

class Album
{
public:
    string name;
    Track[] tracks;
    Artist[] artists;

    this(string name)
    {
        this.name = name;
    }

    Image image()
        => tracks.length > 0 ? tracks[0].image : Image.init;

    int getPlayCount()
    {
        int ret;
        foreach (track; tracks)
            ret += track.getPlayCount();
        return ret;
    }

    void sortTracks()
    {
        tracks.sort!((a, b) => a.number < b.number ||
            (a.number == b.number && a.file.name < b.file.name));
    }
}
