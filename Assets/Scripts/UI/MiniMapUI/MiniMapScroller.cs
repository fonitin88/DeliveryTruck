using UnityEngine;
using UnityEngine.UI;

public class MiniMapCenterScroller : MonoBehaviour
{
    [Header("References")]
    public Transform player;                 // 玩家 Transform
    public RawImage minimapImage;            // MiniMap 的 RawImage
    public RectTransform playerIcon;         // 玩家圖標（必須在 Mask 外面）

    [Header("World Bounds")]
    public Vector2 worldMin = new Vector2(-100, -100);  // 世界最小座標
    public Vector2 worldMax = new Vector2(100, 100);     // 世界最大座標

    [Header("Settings")]
    public bool smoothMovement = true;       // 是否平滑移動
    public float smoothSpeed = 10f;          // 平滑速度

    private RectTransform minimapRect;
    private Vector2 targetPosition;

    void Start()
    {
        // 獲取 RectTransform
        if (minimapImage != null)
        {
            minimapRect = minimapImage.rectTransform;
        }

        // 確保玩家圖標在中心（玩家圖標應該在 Mask 層級，不在 MiniMapImage 裡面）
        if (playerIcon != null)
        {
            playerIcon.anchoredPosition = Vector2.zero;

            // 確保玩家圖標在最上層
            playerIcon.SetAsLastSibling();
        }

        // 初始化目標位置
        targetPosition = Vector2.zero;
    }

    void LateUpdate()
    {
        if (player == null || minimapRect == null)
            return;

        UpdateMinimap();
    }

    void UpdateMinimap()
    {
        // 1. 獲取玩家世界座標
        Vector3 playerPos = player.position;

        // 2. 將世界座標轉換為 0-1 的標準化座標
        float normalizedX = Mathf.InverseLerp(worldMin.x, worldMax.x, playerPos.x);
        float normalizedY = Mathf.InverseLerp(worldMin.y, worldMax.y, playerPos.z);

        // 限制在 0-1 範圍內
        normalizedX = Mathf.Clamp01(normalizedX);
        normalizedY = Mathf.Clamp01(normalizedY);

        // 3. 獲取小地圖的尺寸
        Rect mapRect = minimapRect.rect;
        float mapWidth = mapRect.width;
        float mapHeight = mapRect.height;

        // 4. 計算玩家在地圖上的位置（相對於地圖左下角）
        float mapX = Mathf.Lerp(-mapWidth / 2f, mapWidth / 2f, normalizedX);
        float mapY = Mathf.Lerp(-mapHeight / 2f, mapHeight / 2f, normalizedY);

        // 5. 為了讓玩家圖標保持在中心，地圖需要往反方向移動
        targetPosition = new Vector2(-mapX, -mapY);

        // 6. 應用移動（可選平滑或直接移動）
        if (smoothMovement)
        {
            minimapRect.anchoredPosition = Vector2.Lerp(
                minimapRect.anchoredPosition,
                targetPosition,
                Time.deltaTime * smoothSpeed
            );
        }
        else
        {
            minimapRect.anchoredPosition = targetPosition;
        }
    }

    // 輔助方法：設置世界範圍
    public void SetWorldBounds(Vector2 min, Vector2 max)
    {
        worldMin = min;
        worldMax = max;
    }

    // 在編輯器中顯示世界範圍（Debug用）
    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Vector3 center = new Vector3(
            (worldMin.x + worldMax.x) / 2f,
            0,
            (worldMin.y + worldMax.y) / 2f
        );
        Vector3 size = new Vector3(
            worldMax.x - worldMin.x,
            1,
            worldMax.y - worldMin.y
        );
        Gizmos.DrawWireCube(center, size);
    }
}