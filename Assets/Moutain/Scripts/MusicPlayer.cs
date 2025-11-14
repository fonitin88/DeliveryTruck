using UnityEngine;

public class MusicPlayer : MonoBehaviour
{

    void Start()
    {
        //找出場景中有幾個 MusicPlayer 物件，並記下來
        int numOfMusicPlayers = FindObjectsByType<MusicPlayer>(FindObjectsSortMode.None).Length;

        if (numOfMusicPlayers > 1)
        {
            Destroy(gameObject);
        }
        else
        {
            DontDestroyOnLoad(gameObject);
        }
    }

}
