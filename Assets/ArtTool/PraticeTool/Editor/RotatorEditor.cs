using Codice.Client.BaseCommands;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Rotator))]
public class RotatorEditor : Editor
{
    public override void OnInspectorGUI()
    {

        Rotator rotator = (Rotator)target;

        //undo
        Undo.RecordObject(rotator, "Rotation Y");

        // Slider 取代欄位
        rotator.rotationY = EditorGUILayout.Slider("Rotation Y", rotator.rotationY, -180f, 180f);

        SceneView.RepaintAll();//強制及時繪製
        rotator.ApplyRotation();//apply the change don't need to click the button

        if (GUILayout.Button("Delet Script"))
        {
            Undo.DestroyObjectImmediate(rotator);
        }


        //tell unity to save the change
        if (GUI.changed)
        {
            EditorUtility.SetDirty(rotator);
        }
    }
}
