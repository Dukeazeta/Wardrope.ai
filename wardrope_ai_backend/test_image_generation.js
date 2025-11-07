const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
require('dotenv').config();

async function testImageGeneration() {
  try {
    console.log('🎨 Testing Gemini 2.5 Flash Image Generation...');

    // Initialize the AI client
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-image' });

    // Test prompt
    const prompt = 'Create a picture of a nano banana dish in a fancy restaurant with a Gemini theme. The dish should be elegantly presented on a white plate with garnish, in a luxurious restaurant setting with soft lighting.';

    console.log('📝 Prompt:', prompt);
    console.log('🤖 Generating image...');

    // Generate the image
    const response = await model.generateContent(prompt);

    console.log('✅ Response received!');

    // Look for image data in the response
    let imageData = null;
    let textResponse = '';

    // console.log('🔍 Response structure:', JSON.stringify(response, null, 2));

    // Try different ways to access the response parts
    const responseParts = response.response?.parts || response.response?.candidates?.[0]?.content?.parts || [];

    for (const part of responseParts) {
      if (part.text) {
        textResponse += part.text;
        console.log('💬 Text response:', part.text);
      } else if (part.inlineData) {
        imageData = part.inlineData.data;
        console.log('🖼️  Image data found! Length:', imageData.length);
      }
    }

    // If no parts found, try to get the text response directly
    if (responseParts.length === 0) {
      const text = response.response?.text?.();
      if (text) {
        textResponse = text;
        console.log('💬 Direct text response:', text);
      }
    }

    if (imageData) {
      // Save the image to uploads folder
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const filename = `nano-banana-gemini-${timestamp}.png`;
      const filepath = `./uploads/${filename}`;

      // Convert base64 to buffer and save
      const imageBuffer = Buffer.from(imageData, 'base64');
      fs.writeFileSync(filepath, imageBuffer);

      console.log(`🎉 Image saved successfully!`);
      console.log(`📁 File: ${filepath}`);
      console.log(`📏 Size: ${imageBuffer.length} bytes`);

      return {
        success: true,
        filename,
        filepath,
        size: imageBuffer.length,
        textResponse
      };
    } else {
      console.log('❌ No image data in response');
      console.log('📄 Full response:', JSON.stringify(response.response, null, 2));
      return {
        success: false,
        error: 'No image data in response',
        textResponse
      };
    }

  } catch (error) {
    console.error('❌ Error generating image:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

// Run the test
testImageGeneration().then(result => {
  console.log('\n🏁 Test Result:', JSON.stringify(result, null, 2));
}).catch(error => {
  console.error('💥 Test failed:', error);
});