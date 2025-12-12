using UnityEngine;

public class ColorApply : MonoBehaviour
{
    //仔入 data 和 變色的物件render
    public ColorData colorData;
    public Renderer targetRender;

    void Awake()
    {
        //替代顏色GetComponent<Renderer>()
        //自動抓 Renderer，避免忘記在 Inspector 指派
        if (targetRender == null)
        {
            targetRender = GetComponent<Renderer>();
        }
        if (targetRender != null)
        {
            targetRender.material.SetColor("_TargetColor", colorData.seletedColor);
        }
    }

}
