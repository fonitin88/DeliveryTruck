using System.Collections;
using UnityEngine;

public abstract class Van_PickUp : MonoBehaviour
{
    const string PLAYER_STRING = "Player";
    GameObject targetPlayer;


    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(PLAYER_STRING))
        {
            targetPlayer = other.gameObject;
            StartCoroutine(FlyToPlayerAndPickUp());
        }
    }

    IEnumerator FlyToPlayerAndPickUp()
    {

        Vector3 startPos = transform.position;
        Vector3 endPos = targetPlayer.transform.position + Vector3.up * 2f; // 加一點高度偏移到胸口
        Vector3 startscale = transform.localScale;
        Vector3 endscale = transform.localScale * 0.1f;
        float duration = 0.3f;
        float timer = 0f;


        while (timer < duration)//在這個時間內
        {
            float t = timer / duration;//進度（0 開始 → 0.1 結束）

            // 平滑 Lerp
            Vector3 move = Vector3.Lerp(startPos, endPos, t);//t = 0> startPos, t = 1>endPos
            Vector3 scale = Vector3.Lerp(startscale, endscale, t);

            // 拋物線高度曲線
            float height = Mathf.Sin(t * Mathf.PI) * 3f;
            move.y += height;

            transform.position = move;
            transform.localScale = scale;

            timer += Time.deltaTime;
            yield return null;
        }

        // 飛完後觸發真正撿取邏輯

        OnPickup(targetPlayer);
        Destroy(gameObject);
    }
    protected abstract void OnPickup(GameObject player);


}
