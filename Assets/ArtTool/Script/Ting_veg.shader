Shader "Shader Graphs/pss_vfx_simpleMaskAnimate"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white" {}
        _BaseColor("BaseColor", Color) = (0, 0, 0, 0)
        _DepthFade("DepthFade", Range(0, 1)) = 0.1
        [NoScaleOffset]_DetailMap("DetailMap", 2D) = "black" {}
        _DetailTiling("DetailTiling", Vector) = (1, 1, 0, 0)
        _OffsetSpeed("OffsetSpeed", Vector) = (0, 0, 0, 0)
        _DetailColor("DetailColor", Color) = (1, 1, 1, 1)
        _DetailErosion("DetailErosion", Range(0, 30)) = 1
        [Toggle(_USERANDOMOFFSET)]_USERANDOMOFFSET("UseRandomOffset", Float) = 0
        [NoScaleOffset]_Noise("Noise", 2D) = "white" {}
        _NoiseTilling("NoiseTilling", Vector) = (1, 1, 0, 0)
        _NoiseOffsetSpeed("NoiseOffsetSpeed", Vector) = (0, 0, 0, 0)
        _NoiseColor("NoiseColor", Color) = (0, 0, 0, 0)
        _NoiseErosion("NoiseErosion", Range(0, 50)) = 1
        [KeywordEnum(Normal, Object)]_DISPLACEMENTDIRECTION("DisplacementDirection", Float) = 0
        _Displacement("Displacement", Range(-1, 1)) = 0.5
        _MovingSpeed("MovingSpeed", Range(0, 1)) = 0.5
        _Scale("Scale", Float) = 2
        [HideInInspector]_WorkflowMode("_WorkflowMode", Float) = 1
        [HideInInspector]_CastShadows("_CastShadows", Float) = 0
        [HideInInspector]_ReceiveShadows("_ReceiveShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 1
        [HideInInspector]_Blend("_Blend", Float) = 2
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 0
        [HideInInspector]_BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 0
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 0
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_SHADOW_COORD
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv2 : TEXCOORD2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 staticLightmapUV;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 dynamicLightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 sh;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 probeOcclusion;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 fogFactorAndVertexLight;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 shadowCoord;
            #endif
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TangentSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 staticLightmapUV : INTERP0;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 sh : INTERP2;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 probeOcclusion : INTERP3;
            #endif
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 shadowCoord : INTERP4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentWS : INTERP5;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP7;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 fogFactorAndVertexLight : INTERP8;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP9;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP10;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.BaseColor = (_Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = float(0);
            surface.Occlusion = float(1);
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_SHADOW_COORD
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv2 : TEXCOORD2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 staticLightmapUV;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 dynamicLightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 sh;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 probeOcclusion;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 fogFactorAndVertexLight;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 shadowCoord;
            #endif
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TangentSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 staticLightmapUV : INTERP0;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 sh : INTERP2;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 probeOcclusion : INTERP3;
            #endif
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 shadowCoord : INTERP4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentWS : INTERP5;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP7;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 fogFactorAndVertexLight : INTERP8;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP9;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP10;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.BaseColor = (_Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = float(0);
            surface.Occlusion = float(1);
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TangentSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentWS : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalWS : INTERP4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_INSTANCEID
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv2 : TEXCOORD2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord2 : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.BaseColor = (_Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.BaseColor = (_Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4.xyz);
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local _DISPLACEMENTDIRECTION_NORMAL _DISPLACEMENTDIRECTION_OBJECT
        #pragma shader_feature_local _ _USERANDOMOFFSET
        
        #if defined(_DISPLACEMENTDIRECTION_NORMAL) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_DISPLACEMENTDIRECTION_NORMAL)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DISPLACEMENTDIRECTION_OBJECT) && defined(_USERANDOMOFFSET)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define REQUIRE_DEPTH_TEXTURE
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 ScreenPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 NDCPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float2 PixelPosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             float3 positionWS : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _NoiseColor;
        float4 _BaseMap_TexelSize;
        float4 _BaseMap_ST;
        float _Displacement;
        float _DetailErosion;
        float _DepthFade;
        float _MovingSpeed;
        float4 _Noise_TexelSize;
        float4 _BaseColor;
        float _Scale;
        float2 _OffsetSpeed;
        float2 _NoiseOffsetSpeed;
        float2 _NoiseTilling;
        float4 _DetailMap_TexelSize;
        float4 _DetailColor;
        float _NoiseErosion;
        float2 _DetailTiling;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };
        
        void SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(float _Distance, Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float IN, out float Value_0)
        {
        float _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float);
        float4 _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_82598f76839f4f33aad9f20e15fa8f17_R_1_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[0];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_G_2_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[1];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_B_3_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[2];
        float _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float = _ScreenPosition_99a6446bd82749c1ba22b732be5d1628_Out_0_Vector4[3];
        float _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_6732ab706d094574a736f488ebbdabb6_Out_1_Float, _Split_82598f76839f4f33aad9f20e15fa8f17_A_4_Float, _Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float);
        float _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float = _Distance;
        float _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float;
        Unity_Divide_float(_Subtract_a3f1eaca25dd4ea19c9ec1a056614785_Out_2_Float, _Property_26417eeb49dd45c19ca465a7e22d598b_Out_0_Float, _Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float);
        float _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        Unity_Saturate_float(_Divide_2191e06adbd14ef385e20641bb61b552_Out_2_Float, _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float);
        Value_0 = _Saturate_e7128e764956442fbc03602c7f133b6c_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float = _Displacement;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2 = IN.ObjectSpacePosition.xz;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_176fd214699e4a61a9773941119d0620_Out_0_Float = _Scale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float = _MovingSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float;
            Unity_Multiply_float_float(_Property_c5a67755ea0a4941804a7847fe0e0ed4_Out_0_Float, IN.TimeParameters.x, _Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_ed6e8338679446c8bd4751fab6b7eb09_Out_1_Vector2, (_Property_176fd214699e4a61a9773941119d0620_Out_0_Float.xx), (_Multiply_dc323f7d738d4e5b8ae3e269210c7da6_Out_2_Float.xx), _TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
              float4 _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.tex, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.samplerstate, _Property_722bb2ae85db46eb97a5d67cc79ff330_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cfc6c51465db4c34abecf88f2a20a918_Out_3_Vector2), float(0));
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_G_6_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_B_7_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_A_8_Float = _SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float;
            Unity_Remap_float(_SampleTexture2DLOD_7a905cdfcf0e4ee29247a795dc624cba_R_5_Float, float2 (0, 1), float2 (-0.5, 0.5), _Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_0eb616777cdb49b48fd6278e83fbb121_R_1_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[0];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[1];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_B_3_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[2];
            float _Split_0eb616777cdb49b48fd6278e83fbb121_A_4_Float = _UV_056c381d9994441eb9330e356c908cdb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float;
            Unity_OneMinus_float(_Split_0eb616777cdb49b48fd6278e83fbb121_G_2_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float;
            Unity_Multiply_float_float(_Remap_4dd37b4b82db4fc9bfd36e17c538eb88_Out_3_Float, _OneMinus_5fbeb158a7124b34ae9d3ffd7fb8fa13_Out_1_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float;
            Unity_Multiply_float_float(_Property_82593bf3a9c545e6bb7067952d548a5f_Out_0_Float, _Multiply_edb89cde0fc249dabd2ad66eda440fa4_Out_2_Float, _Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3 = float3(float(1), float(1), float(1));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_a1d349c60b8c409486f75204b2fc045b_Out_0_Vector3, (_Multiply_451a57066e314621a4e6fe291b3a2695_Out_2_Float.xxx), _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_DISPLACEMENTDIRECTION_NORMAL)
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_2ea846e5847f4c4a8bf3c127b8f908ca_Out_2_Vector3;
            #else
            float3 _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3 = _Multiply_809c57dfadd34ebab1adecdcbb291274_Out_2_Vector3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _DisplacementDirection_08c50bdd700f4bcbbaac86f63607b357_Out_0_Vector3, _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3);
            #endif
            description.Position = _Add_c6bce1422a16400490cbde214f6235bd_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4 = _BaseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4 = _NoiseColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Noise);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2 = _NoiseTilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2 = _NoiseOffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ba7358bad36f43438b32fff16cb7f102_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_584b2eff81384a54a17ed85a737d0442_Out_0_Vector2, _Multiply_ea4519cc8386447ebf6eb85f0f55225a_Out_2_Vector2, _TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.tex, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.samplerstate, _Property_0efaf96b84924d3b81f56dc7966dfc63_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_eba4857cb7eb44fbaca9cfdb7d9d8dd3_Out_3_Vector2) );
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.r;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_G_5_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.g;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_B_6_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.b;
            float _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_A_7_Float = _SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D = UnityBuildTexture2DStruct(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.tex, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.samplerstate, _Property_9970143262124a5cbc43c7c323f4f06c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.r;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_G_5_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.g;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_B_6_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.b;
            float _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_A_7_Float = _SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float = _NoiseErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_c5acda4b18434725abbaa617e88a5313_Out_0_Float, _Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float;
            Unity_OneMinus_float(_Multiply_0bfed0a0e66043869c4fe16664fabfb7_Out_2_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_41943649c86b418eab3f065d6c6e0c17_R_4_Float, _OneMinus_8397acff38e44fdaa42ffd20645f0d20_Out_1_Float, _Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float;
            Unity_Saturate_float(_Subtract_d28dac0f3e94408fa58678e441afc029_Out_2_Float, _Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4;
            Unity_Lerp_float4(_Property_c56a54f37b9745a7b90bf990f818f769_Out_0_Vector4, _Property_8f2a4d3768dc45068eb0798ae2d079f4_Out_0_Vector4, (_Saturate_789ee3091f884694aaafcdfd8ff92be6_Out_1_Float.xxxx), _Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4 = _DetailColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_de505611251347c392494b67c91bca37_Out_0_Vector2 = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2 = _OffsetSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c5f99b7cbe8e44f1be98e610da36d7be_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Float_c995f6625bd54886a1271643d1128bba_Out_0_Float = float(47);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float = _UV_ffdf0af47ae241a0b84f53160a606bdf_Out_0_Vector4.y;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            Unity_Multiply_float_float(_Float_c995f6625bd54886a1271643d1128bba_Out_0_Float, _Swizzle_1a281044180c4196809fdb48c1b91ac1_Out_1_Float, _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(_USERANDOMOFFSET)
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = _Multiply_a7a61f1d3b4345008cdd83a0ecb8fba1_Out_2_Float;
            #else
            float _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float = float(0);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2 = float2(float(0), _UseRandomOffset_462c87e4d6d54548ad5cdd9544d492ce_Out_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2;
            Unity_Add_float2(_Multiply_a6b50ccbf2024fc9be04ba6c4b4dda41_Out_2_Vector2, _Vector2_33e39963d2634608a4f47a83d0e528fd_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2;
            Unity_TilingAndOffset_float((_UV_2d058e652dbd43f19b14bb56cbfd63ed_Out_0_Vector4.xy), _Property_de505611251347c392494b67c91bca37_Out_0_Vector2, _Add_cc3d7127832c40c8903cc9ff43d78881_Out_2_Vector2, _TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.tex, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.samplerstate, _Property_1c696b171b99428aacce874b5e781753_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_f034db399ffc4997a0379535f24e51b8_Out_3_Vector2) );
            float _SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.r;
            float _SampleTexture2D_51787cca581f479f929f916410357571_G_5_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.g;
            float _SampleTexture2D_51787cca581f479f929f916410357571_B_6_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.b;
            float _SampleTexture2D_51787cca581f479f929f916410357571_A_7_Float = _SampleTexture2D_51787cca581f479f929f916410357571_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float = _DetailErosion;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_b87c82696a504ce4981a1eaeabea15be_R_4_Float, _Property_03c70bf5291a4759a43d461cc6caf6a0_Out_0_Float, _Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float;
            Unity_OneMinus_float(_Multiply_e9d1f4e5013a4c90a622a8107c9ab087_Out_2_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float;
            Unity_Subtract_float(_SampleTexture2D_51787cca581f479f929f916410357571_R_4_Float, _OneMinus_c3d1da0fcf0e4e4a812a5569587f16ed_Out_1_Float, _Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float;
            Unity_Saturate_float(_Subtract_a18d8d740b6e459a97e7fcffef29ced8_Out_2_Float, _Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_8426d5b2931641f2a963415d9cd09b76_Out_3_Vector4, _Property_8445963f67da4fa988291b1b0d09b0c4_Out_0_Vector4, (_Saturate_cb69c3482e8f44b88966ff30b21ffab8_Out_1_Float.xxxx), _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_R_1_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[0];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_G_2_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[1];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_B_3_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[2];
            float _Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float = _Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float = _DepthFade;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.ScreenPosition = IN.ScreenPosition;
            _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f.NDCPosition = IN.NDCPosition;
            float _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float;
            SG_SubGraphDepthFade_a1efd1a3607ff7b44a3b4a7e15e07b3c_float(_Property_da3708fd84894cf899633b6fd605d00f_Out_0_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            Unity_Multiply_float_float(_Split_7f43a876903d4dc7b7913b91b6d626b8_A_4_Float, _SubGraphDepthFade_7985d9479ab84d9a8c6d2072e7c3749f_Value_0_Float, _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float);
            #endif
            surface.BaseColor = (_Lerp_2c99f0bcc5ef44cbbaa0ea395da9ace0_Out_3_Vector4.xyz);
            surface.Alpha = _Multiply_d5988e5210404029978c3d916c632098_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #else
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
        
            #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 = input.texCoord1;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}