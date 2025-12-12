using UnityEngine;
//ScriptableObject即時共用狀態
[CreateAssetMenu(fileName = "ColorData", menuName = "Scriptable Objects/ColorData")]
public class ColorData : ScriptableObject
{
    public Color seletedColor = Color.white;
}
