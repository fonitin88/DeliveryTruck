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
        redBtn.onClick.AddListener(() => OnColorSelected(Color.red));
        yellowBtn.onClick.AddListener(() => OnColorSelected(Color.yellow));
        blueBtn.onClick.AddListener(() => OnColorSelected(Color.blue));
        resetBtn.onClick.AddListener(() => OnColorSelected(Color.white));

    }
    //選了顏色後更新到data / view / save
    void OnColorSelected(Color color)
    {
        colorData.seletedColor = color;
        colorView.UpdateColor(color);
        PlayerPrebManager.SaveColor(color);
    }

}
