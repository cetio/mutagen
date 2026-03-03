module mutagen.artist;

import mutagen.album;
import mutagen.image;

class Artist
{
public:
    string name;
    Album[] albums;

    this(string name)
    {
        this.name = name;
    }

    Image image()
        => albums.length > 0 ? albums[0].image : Image.init;

    int getPlayCount()
    {
        int ret;
        foreach (album; albums)
            ret += album.getPlayCount();
        return ret;
    }
}
