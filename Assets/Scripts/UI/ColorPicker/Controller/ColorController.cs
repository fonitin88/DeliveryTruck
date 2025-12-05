using JetBrains.Annotations;
using UnityEngine;
using UnityEngine.UI;

public class ColorController : MonoBehaviour
{
    [Header("References")]
    //把data view gameobj button 帶進去 
    public ColorData colorData;
    public ColorView colorView;
    public Button resetBtn;
    public Button redBtn;
    public Button yellowBtn;
    public Button blueBtn;

    void Start()
    {

        // 從資料庫載入顏色和 更新顏色
        colorData.seletedColor = PlayerPrebManager.LoadColor();
        colorView.UpdateColor(colorData.seletedColor);

        //按鈕寫上功能
        redBtn.onClick.AddListener(() => OnColorSelected(new Color(1.000f, 0.231f, 0.486f, 1.000f)));
        yellowBtn.onClick.AddListener(() => OnColorSelected(new Color(1.000f, 0.816f, 0.000f, 1.000f)));
        blueBtn.onClick.AddListener(() => OnColorSelected(new Color(0.039f, 0.302f, 0.792f, 1.000f)));
        resetBtn.onClick.AddListener(() => OnColorSelected(new Color(0.000f, 0.655f, 0.510f, 1.000f)));

    }
    //選了顏色後更新到data / view / save
    void OnColorSelected(Color color)
    {
        colorData.seletedColor = color;
        colorView.UpdateColor(color);
        PlayerPrebManager.SaveColor(color);
    }

}
