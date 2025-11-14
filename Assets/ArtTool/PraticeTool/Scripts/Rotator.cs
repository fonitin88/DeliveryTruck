using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    [HideInInspector] public float rotationY;
    List<float> childBaseRotation = new List<float>();

    void RefreshChildRotations()
    {
        childBaseRotation.Clear(); //initialize
        foreach (Transform child in transform)
        {
            childBaseRotation.Add(child.localEulerAngles.y);
        }
        rotationY = 0f;
    }

    public void ApplyRotation()
    {
        if (transform.childCount != childBaseRotation.Count)
        {
            RefreshChildRotations();
        }

        int index = 0;
        foreach (Transform child in transform)
        {
            float newY = childBaseRotation[index] + rotationY;
            child.localRotation = Quaternion.Euler(0, newY, 0);
            index++;
        }
    }

}
