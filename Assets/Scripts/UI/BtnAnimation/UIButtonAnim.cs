using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;


public class UIButtonAnim : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler
{
    [SerializeField] float pressScale = 0.9f;
    [SerializeField] float animTime = 0.08f;
    [SerializeField] float brightness = 0.8f;

    Vector3 defalutScale;
    Color basecolor;
    Image targetImage;

    void Awake()
    {

        defalutScale = transform.localScale;
        targetImage = GetComponent<Image>();
        basecolor = targetImage.color;
    }
    public void OnPointerDown(PointerEventData eventData)
    {
        StopAllCoroutines();
        StartCoroutine(ScaleTo(defalutScale * pressScale));
        StartCoroutine(BrightnessTo(basecolor * brightness));
    }
    public void OnPointerUp(PointerEventData eventData)
    {
        StopAllCoroutines();
        StartCoroutine(ScaleTo(defalutScale));
        StartCoroutine(BrightnessTo(basecolor));
    }
    public void OnPointerEnter(PointerEventData eventData)
    {


    }

    public void OnPointerExit(PointerEventData eventData)
    {
        StopAllCoroutines();
        StartCoroutine(ScaleTo(defalutScale));
        StartCoroutine(BrightnessTo(basecolor));
    }
    System.Collections.IEnumerator ScaleTo(Vector3 target)
    {
        Vector3 start = transform.localScale;
        float t = 0f;
        while (t < animTime)
        {
            t += Time.unscaledDeltaTime;
            transform.localScale = Vector3.Lerp(start, target, t / animTime);
            yield return null;
        }
        transform.localScale = target;
    }
    System.Collections.IEnumerator BrightnessTo(Color finalColor)
    {
        Color start = targetImage.color;
        float t = 0f;
        while (t < animTime)
        {
            t += Time.unscaledDeltaTime;
            targetImage.color = Color.Lerp(start, finalColor, t / animTime);
            yield return null;
        }
        targetImage.color = finalColor;
    }



}
