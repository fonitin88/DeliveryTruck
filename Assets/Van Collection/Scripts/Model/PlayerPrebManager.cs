using UnityEngine;

public class PlayerPrebManager
{
    //save
    public static void SaveColor(Color color)
    {
        PlayerPrefs.SetFloat("R", color.r);
        PlayerPrefs.SetFloat("G", color.g);
        PlayerPrefs.SetFloat("B", color.b);
        PlayerPrefs.Save();
    }

    //load
    public static Color LoadColor(Color defaultColor)
    {
        if (PlayerPrefs.HasKey("R"))
        {
            float r = PlayerPrefs.GetFloat("R");
            float g = PlayerPrefs.GetFloat("G");
            float b = PlayerPrefs.GetFloat("B");
            return new Color(r, g, b);
        }
        return defaultColor;
    }

}
