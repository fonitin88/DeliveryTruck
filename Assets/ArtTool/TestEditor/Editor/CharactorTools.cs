using UnityEngine;
using UnityEditor;

public class CharactorTools
{
    public void Draw()
    {
        if (GUILayout.Button("character folder"))
        {
            string _path = "Assets/Arts/Charater";
            Object _o = AssetDatabase.LoadAssetAtPath(_path, typeof(Object));
            Selection.activeObject = _o;

        }

    }

}
