# -*- coding: utf-8 -*-
"""
Script to generate a comprehensive, executive HTML report and convert it to PDF via headless Microsoft Edge.
Tailored specifically for the Founder / Project Owner of "Qatfa" (منصة قطفة).
"""

import os
import subprocess
import sys

html_content = """<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
<meta charset="utf-8">
<title>منصة قطفة - الدليل التنفيذي الشامل لصاحب المشروع</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700;800;900&display=swap');

  @page {
    size: A4;
    margin: 15mm 15mm 15mm 15mm;
    @bottom-center {
      content: counter(page);
    }
  }

  * {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  body {
    font-family: 'Cairo', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    direction: rtl;
    text-align: right;
    color: #2D3748;
    background-color: #FFFFFF;
    margin: 0;
    padding: 0;
    font-size: 13px;
    line-height: 1.6;
  }

  .page-break {
    page-break-after: always;
    break-after: page;
  }

  .avoid-break {
    page-break-inside: avoid;
    break-inside: avoid;
  }

  /* Cover Page Styling */
  .cover-container {
    height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 30px 20px;
    background: linear-gradient(145deg, #0d3813 0%, #1B5E20 40%, #2E7D32 100%);
    color: #FFFFFF;
    border-radius: 12px;
  }

  .cover-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid rgba(255,255,255,0.2);
    padding-bottom: 15px;
  }

  .cover-badge {
    background: #E65100;
    color: #FFF;
    padding: 6px 14px;
    border-radius: 20px;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.5px;
  }

  .cover-meta {
    font-size: 13px;
    opacity: 0.9;
  }

  .cover-body {
    margin-top: 40px;
    margin-bottom: 40px;
  }

  .cover-tagline {
    color: #A5D6A7;
    font-size: 16px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    margin-bottom: 15px;
  }

  .cover-title {
    font-size: 42px;
    font-weight: 900;
    line-height: 1.2;
    margin: 0 0 20px 0;
    color: #FFFFFF;
    text-shadow: 0 2px 4px rgba(0,0,0,0.3);
  }

  .cover-subtitle {
    font-size: 18px;
    line-height: 1.6;
    color: #E8F5E9;
    max-width: 800px;
    font-weight: 400;
    border-right: 4px solid #E65100;
    padding-right: 15px;
  }

  .cover-highlights {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 15px;
    margin-top: 40px;
  }

  .highlight-card {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(5px);
    border: 1px solid rgba(255,255,255,0.25);
    padding: 16px;
    border-radius: 10px;
    text-align: center;
  }

  .highlight-card .number {
    font-size: 26px;
    font-weight: 800;
    color: #FFE082;
    margin-bottom: 5px;
  }

  .highlight-card .label {
    font-size: 12px;
    color: #E8F5E9;
    font-weight: 600;
  }

  .cover-footer {
    border-top: 1px solid rgba(255,255,255,0.2);
    padding-top: 20px;
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    font-size: 12px;
    color: #C8E6C9;
  }

  /* Document Body Typography */
  h1, h2, h3, h4 {
    font-family: 'Cairo', sans-serif;
    color: #1B5E20;
    margin-top: 0;
  }

  h1.section-title {
    font-size: 22px;
    font-weight: 800;
    border-bottom: 3px solid #1B5E20;
    padding-bottom: 8px;
    margin-bottom: 18px;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  h1.section-title .section-num {
    background: #E8F5E9;
    color: #1B5E20;
    font-size: 14px;
    padding: 3px 10px;
    border-radius: 12px;
    font-weight: 700;
  }

  h2.subsection-title {
    font-size: 16px;
    font-weight: 700;
    color: #2E7D32;
    margin-top: 18px;
    margin-bottom: 10px;
    border-right: 4px solid #E65100;
    padding-right: 10px;
  }

  h3 {
    font-size: 14px;
    font-weight: 700;
    color: #1F2937;
    margin-top: 14px;
    margin-bottom: 8px;
  }

  p {
    margin-top: 0;
    margin-bottom: 10px;
    text-align: justify;
  }

  /* Executive Callouts & Alerts */
  .alert-box {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 12.5px;
    border-right: 4px solid;
  }

  .alert-box.info {
    background-color: #E8F5E9;
    border-color: #1B5E20;
    color: #144018;
  }

  .alert-box.warning {
    background-color: #FFF3E0;
    border-color: #E65100;
    color: #7E2A00;
  }

  .alert-box.tip {
    background-color: #E3F2FD;
    border-color: #1976D2;
    color: #0D47A1;
  }

  .alert-title {
    font-weight: 700;
    margin-bottom: 4px;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  /* Cards & Grids */
  .grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
    margin-bottom: 14px;
  }

  .grid-3 {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
    margin-bottom: 14px;
  }

  .grid-4 {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin-bottom: 14px;
  }

  .card {
    background: #FFFFFF;
    border: 1px solid #E2E8F0;
    border-radius: 8px;
    padding: 14px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  }

  .card.featured {
    border-top: 3px solid #1B5E20;
  }

  .card.accent {
    border-top: 3px solid #E65100;
  }

  .card-title {
    font-weight: 700;
    font-size: 14px;
    color: #1B5E20;
    margin-bottom: 8px;
  }

  /* Tables */
  table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 10px;
    margin-bottom: 16px;
    font-size: 12px;
  }

  th, td {
    border: 1px solid #E2E8F0;
    padding: 9px 11px;
    text-align: right;
  }

  th {
    background-color: #1B5E20;
    color: #FFFFFF;
    font-weight: 700;
  }

  tr:nth-child(even) {
    background-color: #F8FAF9;
  }

  td.highlight {
    font-weight: 700;
    color: #1B5E20;
  }

  .badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 700;
  }

  .badge.success { background: #E8F5E9; color: #2E7D32; }
  .badge.warning { background: #FFF3E0; color: #E65100; }
  .badge.neutral { background: #EDF2F7; color: #4A5568; }

  /* Roadmap & Timeline styling */
  .timeline-step {
    border-right: 3px solid #1B5E20;
    padding-right: 14px;
    margin-bottom: 14px;
    position: relative;
  }

  .timeline-step::before {
    content: '';
    position: absolute;
    right: -8px;
    top: 4px;
    width: 13px;
    height: 13px;
    border-radius: 50%;
    background: #E65100;
    border: 2px solid #FFFFFF;
  }

  .timeline-step h4 {
    margin: 0 0 4px 0;
    color: #1B5E20;
    font-size: 13.5px;
  }

  /* Footer */
  .doc-footer {
    font-size: 10.5px;
    color: #A0AEC0;
    border-top: 1px solid #E2E8F0;
    padding-top: 8px;
    margin-top: 20px;
    display: flex;
    justify-content: space-between;
  }

  ul, ol {
    margin-top: 0;
    margin-bottom: 10px;
    padding-right: 20px;
  }

  li {
    margin-bottom: 4px;
  }
</style>
</head>
<body>

<!-- ==================== COVER PAGE ==================== -->
<div class="cover-container page-break">
  <div class="cover-header">
    <div class="cover-badge">وثيقة استراتيجية وتنفيذية سرية</div>
    <div class="cover-meta">نوفمبر 2026 | الإصدار المعتمد 1.0</div>
  </div>

  <div class="cover-body">
    <div class="cover-tagline">من الفكرة إلى الريادة السوقية | الجمهورية اليمنية</div>
    <div class="cover-title">منصة قطفة (Qatfa)</div>
    <div class="cover-subtitle">
      الدليل التنفيذي الشامل لصاحب المشروع: الرؤية الاستراتيجية، تحليل الجدوى ونموذج الربحية، ونطاق الإطلاق الميداني السريع لأكبر شبكة تجارية واجتماعية لسوق القات في اليمن.
    </div>

    <div class="cover-highlights">
      <div class="highlight-card">
        <div class="number">3-5 مليار $</div>
        <div class="label">حجم التداول السنوي التقديري لسوق القات</div>
      </div>
      <div class="highlight-card">
        <div class="number">10 أسابيع</div>
        <div class="label">الجدول الزمني للإطلاق الميداني للنسخة الأولى</div>
      </div>
      <div class="highlight-card">
        <div class="number">&lt; 80 $ شهرياً</div>
        <div class="label">التكلفة التشغيلية للخوادم والتقنية (Lean)</div>
      </div>
    </div>
  </div>

  <div class="cover-footer">
    <div>
      <strong>إعداد:</strong> الفريق الاستشاري المشترك (إدارة المنتجات، المعمارية البرمجية، وهندسة الأعمال)<br>
      <strong>الموجَّه إليه:</strong> صاحب الفكرة والمؤسس الرئيسي لمشروع قطفة
    </div>
    <div style="text-align: left;">
      منصة قطفة للتقنية والتجارة الرقمية<br>
      صنعاء - عدن، الجمهورية اليمنية
    </div>
  </div>
</div>


<!-- ==================== EXECUTIVE SUMMARY & INDEX ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>الملخص التنفيذي وفهرس الوثيقة</span>
    <span class="section-num">نظرة عامة</span>
  </h1>

  <div class="alert-box info">
    <div class="alert-title">💡 رسالة موجهة لصاحب الفكرة</div>
    تم إعداد هذا التقرير ليكون مرجعك الشامل والنهائي لفهم كافة تفاصيل المشروع دون الغوص في شفرات البرمجة أو التعقيدات التقنية البحتة. إنه يجيب على الأسئلة الجوهرية: <strong>ماذا سنبني؟ لماذا اخترنا هذا النموذج تحديداً؟ كيف سنجني الأرباح؟ كم سيكلفنا المشروع؟ وما هي المخاطر وكيف أمّنا ظهورنا منها؟</strong>
  </div>

  <h2 class="subsection-title">فهرس محتويات التقرير</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 15%;">القسم</th>
        <th style="width: 50%;">الموضوع الرئيسي</th>
        <th style="width: 35%;">أهم النقاط التي يغطيها</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">القسم الأول</td>
        <td><strong>الفرصة الاستثمارية والرؤية الجوهرية</strong></td>
        <td>واقع سوق القات، حجم الإنفاق، المشكلة التي نحلها، والتحول الرقمي.</td>
      </tr>
      <tr>
        <td class="highlight">القسم الثاني</td>
        <td><strong>نقد النموذج الساذج ونزع المخاطر المبكر</strong></td>
        <td>لماذا تجنبنا التوصيل والدفع الإلكتروني في MVP؟ وما هو البديل الناجح؟</td>
      </tr>
      <tr>
        <td class="highlight">القسم الثالث</td>
        <td><strong>المنتج والجمهور المستهدف (شخصيات المستخدمين)</strong></td>
        <td>المقاوتي (العم صالح)، المشتري اليومي (محمد)، ومشتري المناسبات.</td>
      </tr>
      <tr>
        <td class="highlight">القسم الرابع</td>
        <td><strong>نطاق النسخة الأولى (MVP Scope)</strong></td>
        <td>ما الذي سيتم بناؤه بدقة، وما تم تأجيله ولماذا؟</td>
      </tr>
      <tr>
        <td class="highlight">القسم الخامس</td>
        <td><strong>نموذج العمل واستراتيجية الأرباح (Monetization)</strong></td>
        <td>باقات المتاجر المعتمدة، الإعلانات، وتحليل نقطة التعادل (Break-even).</td>
      </tr>
      <tr>
        <td class="highlight">القسم السادس</td>
        <td><strong>التسويق الميداني والاستحواذ على التجار</strong></td>
        <td>فريق "سفراء قطفة"، ملصقات QR Code في الأسواق، والنمو الفيروسي.</td>
      </tr>
      <tr>
        <td class="highlight">القسم السابع</td>
        <td><strong>الميزانية الواقعية والتكاليف الاستثمارية</strong></td>
        <td>تكلفة التأسيس والتطوير، التكلفة التشغيلية (&lt; 80$)، وتوقعات العائد.</td>
      </tr>
      <tr>
        <td class="highlight">القسم الثامن</td>
        <td><strong>إدارة المخاطر وسياسات Google Play</strong></td>
        <td>استراتيجية النشر الحذر، التوزيع الموازي (APK و تيليجرام)، ومكافحة التضليل.</td>
      </tr>
      <tr>
        <td class="highlight">القسم التاسع</td>
        <td><strong>الجدول الزمني للإطلاق وخارطة الطريق</strong></td>
        <td>خطة الـ 10 أسابيع، مراحل التوسع لـ 24 شهراً، والخطوات الفورية المطلوبة.</td>
      </tr>
    </tbody>
  </table>

  <h2 class="subsection-title">ما هي "قطفة" في سطرين؟</h2>
  <p>
    <strong>قطفة (Qatfa)</strong> هي <strong>المنظومة الرقمية والشبكة الموحدة لتجارة واستكشاف القات في اليمن</strong>؛ تجمع بائعي القات (المقاوتية) في أسواق اليمن بالمستهلكين لحظة بلحظة، وتنهي فوضى التشتت في مجموعات الواتساب، وتتيح للمشتري مشاهدة العروض المتجددة والأسعار وخريطة السوق والتواصل المباشر مع المقاوتي بضغطة زر واحدة.
  </p>

  <h2 class="subsection-title">الركائز السبع الأساسية الحاكمة للمشروع</h2>
  <div class="grid-2" style="margin-top: 10px;">
    <div class="card featured">
      <div class="card-title">1. بيع القات وصوره وأنواعه وخريطة السوق</div>
      <p style="font-size: 11.5px; margin:0;">عرض تشكيلة القات المتكاملة (همداني، شامي، قعطبي...) بصور حقيقية وتقييمات ومراسلة المقاوتي، مع استعراض خريطة تفاعلية لأسواق القات في اليمن وموقع مفرش البائع.</p>
    </div>
    <div class="card featured">
      <div class="card-title">2. إنهاء فوضى مجموعات الواتساب والتليجرام</div>
      <p style="font-size: 11.5px; margin:0;">يستعرض المشتري كافة الصور والأسعار والمناطق وأسماء المقاوتية في مكان واحد منظم، ويتواصل فوراً دون التنقل المشتت بين عشرات المجموعات.</p>
    </div>
    <div class="card featured">
      <div class="card-title">3. العروض المتجددة وحالة [متوفر / نفد]</div>
      <p style="font-size: 11.5px; margin:0;">صور حقيقية ملتقطة مباشرة، أسعار واضحة ومحددة، وقت التحديث بالدقائق ("تم التحديث قبل 10 دقائق")، وزر فوري لحالة البضاعة [متوفر / نفد].</p>
    </div>
    <div class="card featured">
      <div class="card-title">4. ثقة المشتري وتوثيق أرقام البائعين</div>
      <p style="font-size: 11.5px; margin:0;">توثيق إلزامي لأرقام المقاوتية برمز OTP مع شارة توثيق رسمية، وزر سريع للإبلاغ عن أي عروض مضللة مع تجميد آلي للمراجعة.</p>
    </div>
    <div class="card featured">
      <div class="card-title">5. سرعة فائقة وخفة استهلاك باقات النت</div>
      <p style="font-size: 11.5px; margin:0;">فتح التطبيق فورياً خلال أقل من 1.5 ثانية واستهلاك اقتصادي جداً للبيانات ملائم لشبكات 3G وباقات الإنترنت الضعيفة في اليمن.</p>
    </div>
    <div class="card featured">
      <div class="card-title">6. فائدة واضحة للمقاوتي بدون أي عبء تشغيلي</div>
      <p style="font-size: 11.5px; margin:0;">جلب زبائن جدد ومبيعات سريعة في 30 ثانية يومياً دون أن يضيف التطبيق أي عبء إداري أو كتابي على عمل المقاوتي الميداني في السوق.</p>
    </div>
  </div>
  <div class="card featured" style="margin-top: 10px; background-color: #F8FAF9;">
    <div class="card-title" style="color: #E65100;">7. تسويق مستمر ومشاركة ذكية بروابط مباشرة (Deep Linking)</div>
    <p style="font-size: 11.5px; margin:0;">توليد بطاقة مصورة جذابة للعرض ومشاركتها على منصات التواصل (حالات واتساب، فيسبوك، تليجرام)؛ مع رابط مباشر ذكي ينقل المشتري من أي محادثة مباشرة إلى تفاصيل العرض داخل تطبيق «قطفة».</p>
  </div>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 2</span>
  </div>
</div>


<!-- ==================== SECTION 1: VISION & OPPORTUNITY ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم الأول: الرؤية الاستراتيجية وحجم الفرصة السوقية</span>
    <span class="section-num">01</span>
  </h1>

  <h2 class="subsection-title">1. واقع سوق القات في اليمن بالأرقام</h2>
  <p>
    يمثل سوق القات في الجمهورية اليمنية حالة فريدة عالمياً؛ فهو ليس مجرد تجارة زراعية، بل هو <strong>أضخم حركة تداول نقدي يومي</strong> في البلاد، وظاهرة اجتماعية واقتصادية مترسخة:
  </p>

  <div class="grid-3">
    <div class="card accent">
      <div style="font-size: 20px; font-weight: 800; color: #E65100;">+12 مليون</div>
      <div style="font-weight: 700; margin-bottom: 5px;">مستهلك يومي</div>
      <p style="font-size: 11px; margin:0;">يتخذون قرار الشراء يومياً ما بين الساعة 11:30 صباحاً و 3:30 عصراً في جميع المحافظات.</p>
    </div>
    <div class="card accent">
      <div style="font-size: 20px; font-weight: 800; color: #E65100;">3 إلى 5 مليار $</div>
      <div style="font-weight: 700; margin-bottom: 5px;">حجم الإنفاق السنوي</div>
      <p style="font-size: 11px; margin:0;">تقديرات اقتصادية لحجم التدفقات النقدية السنوية المتداولة في قطاع القات اليمني بمختلف أنواعه.</p>
    </div>
    <div class="card accent">
      <div style="font-size: 20px; font-weight: 800; color: #E65100;">صفر منافسة</div>
      <div style="font-weight: 700; margin-bottom: 5px;">غياب الرقمنة المؤسسية</div>
      <p style="font-size: 11px; margin:0;">لا توجد أي منصة رقمية مركزية موثوقة تنظم هذا السوق حتى الآن، مما يمنح "قطفة" ميزة الريادة واحتكار الصدارة.</p>
    </div>
  </div>

  <h2 class="subsection-title">2. المشكلات الجوهرية في النموذج التقليدي</h2>
  <ul>
    <li><strong>عشوائية الأسعار والجودة:</strong> تفاوت حاد في الأسعار لنفس الصنف في نفس اليوم بسبب غياب الشفافية، حيث يدفع المشتري ثمناً غير عادل لعدم معرفته بالبدائل.</li>
    <li><strong>الحساسية الفائقة لتلف السلعة (Extreme Perishability):</strong> القات يُقطف فجراً في المزارع ويصل السوق ظهراً، ويفقد قيمته التسويقية بعد 4 إلى 5 ساعات؛ ما يعني أن عامل الوقت يمثل حياة أو موت للتاجر.</li>
    <li><strong>إهدار وقت المشتري اليومي:</strong> يقضي الموظف أو المستهلك من 45 إلى 60 دقيقة يومياً في حرارة الشمس والزحام الخانق في الأسواق الشعبية للبحث عن طلبته أو الاستفسار عن وصول بضاعة مقاوتيه.</li>
    <li><strong>محدودية انتشار المقاوتي:</strong> التاجر محصور في دائرة زبائن السوق الفيزيائي الذين يمرون أمام دكانه أو مفرشه فقط، ويعجز عن الوصول لزبائن في الأحياء المجاورة مستعدين لدفع أسعار أفضل مقابل جودته.</li>
  </ul>

  <h2 class="subsection-title">3. المقارنة بين الوضع التقليدي ومنظومة "قطفة"</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 25%;">وجه المقارنة</th>
        <th style="width: 35%;">الوضع التقليدي (قبل قطفة)</th>
        <th style="width: 40%;">مع منصة "قطفة"</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">اكتشاف البضاعة ومجموعات الواتساب</td>
        <td>التشتت بين عشرات مجموعات الواتساب وقنوات التليجرام أو المشي في الزحام.</td>
        <td>موجز موحد يعرض عروض المقاوتية والأسعار والمناطق في مكان واحد دون تنقل بين مجموعات.</td>
      </tr>
      <tr>
        <td class="highlight">العروض المتجددة وحالتها</td>
        <td>الجهل بموعد وصول القات أو ما إذا كان قد نفد.</td>
        <td>صور حقيقية ملتقطة مباشرة، أسعار واضحة، ووقت تحديث بالدقائق، مع زر [متوفر / نفد].</td>
      </tr>
      <tr>
        <td class="highlight">خريطة وموقع السوق</td>
        <td>صعوبة العثور على مفرش المقاوتي داخل أزقة السوق المزدحم.</td>
        <td>خريطة تفاعلية لأسواق القات في اليمن تُظهر موقع مفرش التاجر بدقة لتسهيل الوصول إليه.</td>
      </tr>
      <tr>
        <td class="highlight">السمعة وثقة المشتري</td>
        <td>تعتمد على الحظ ومخاطر القات المغشوش والأسعار الوهمية.</td>
        <td>أرقام بائعين موثقة برمز OTP، تقييمات حقيقية، وزر سريع للإبلاغ عن العروض المضللة.</td>
      </tr>
      <tr>
        <td class="highlight">عبء العمل على المقاوتي</td>
        <td>انشغال التاجر بالرد المتكرر والمشتت في الواتساب أو انتظار المارة.</td>
        <td>فائدة فورية بجلب زبائن جدد ومبيعات سريعة في 30 ثانية دون أي عبء تشغيلي على عمله.</td>
      </tr>
      <tr>
        <td class="highlight">التسويق والنشر الذكي</td>
        <td>إعادة إرسال الصور يدوياً في المجموعات مع فقدان الجودة.</td>
        <td>مشاركة العروض بروابط مباشرة ذكية (Deep Links) تنقل المشتري فوراً إلى العرض في التطبيق.</td>
      </tr>
      <tr>
        <td class="highlight">سرعة التطبيق واستهلاك النت</td>
        <td>بطء تنزيل الوسائط واستنزاف رصيد وباقات الإنترنت.</td>
        <td>سرعة فتح فائقة (&lt; 1.5s) وتصفح خفيف جداً متوافق مع باقات 3G اليمنية.</td>
      </tr>
    </tbody>
  </table>

  <div class="alert-box tip">
    <div class="alert-title">🎯 الهدف الاستراتيجي للمشروع</div>
    أن تصبح "قطفة" هي التطبيق الأول الذي يفتحه كل يمني يومياً عند الساعة 12:00 ظهراً، واحتكار نقطة الاتصال والبحث التجاري الأكثر نشاطاً في البلاد.
  </div>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 3</span>
  </div>
</div>


<!-- ==================== SECTION 2: DE-RISKING & SMART SCOPE ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم الثاني: نقد الفكرة ونزع المخاطر المبكر (Smart De-risking)</span>
    <span class="section-num">02</span>
  </h1>

  <div class="alert-box warning">
    <div class="alert-title">⚠️ كيف تحمي استثمارك من الفخاخ الشائعة؟</div>
    معظم المشاريع البرمجية التي تفشل في بدايتها تسقط بسبب <strong>"المبالغة في التعقيد وتجاهل ثقافة السوق المحلي"</strong>. في هذا المشروع، قمنا بنقد الفكرة الأولية وتجريدها من المخاطر التشغيلية القاتلة لنبدأ بنموذج رابح من اليوم الأول.
  </div>

  <h2 class="subsection-title">1. الأخطاء الساذجة التي تم تجنبها بوعي</h2>
  
  <div class="card" style="margin-bottom: 12px;">
    <div class="card-title" style="color: #D32F2F;">❌ الخطأ الأول: بناء "أمازون أو طلبات القات" (توصيل + دفع إلكتروني مباشر) من اليوم الأول</div>
    <p><strong>لماذا هذا النموذج محكوم بالفشل التشغيلي في اليمن حالياً؟</strong></p>
    <ul>
      <li><strong>طبيعة المستهلك اليمني:</strong> القات ليس سلعة استهلاكية معلبة؛ المشتري يحب "معاينة الحزمة" أو يعتمد على ثقة عمياء بالمقاوتي، ولن يدفع قيمتها مسبقاً في تطبيق مجهول.</li>
      <li><strong>طبيعة الدفع النقدي:</strong> أكثر من 85% من التعاملات اليومية في اليمن تتم نقداً باليد (كاش)، وفرض محافظ إلكترونية كشرط إلزامي سينفر 90% من الزبائن والتجار.</li>
      <li><strong>مخاطر أساطيل التوصيل:</strong> القات سريع التلف وحساس للحرارة وشمس الظهيرة، والزحام الخانق في مدن كصنعاء وعدن سيتسبب في تأخير السائقين وتلف السلعة ونزاعات يومية مستمرة تحرق ميزانية الشركة.</li>
    </ul>
    <p style="margin: 0; color: #1B5E20; font-weight: 700;">
      ✔️ الحل الاستراتيجي في قطفة: فصل الاستكشاف وبناء السمعة عن اللوجستيات؛ نبدأ كمنصة "اكتشاف وتواصل وحجز سريع"، ويستلم الزبون القات بنفسه أو يرتب التوصيل مباشرة مع التاجر.
    </p>
  </div>

  <div class="card" style="margin-bottom: 12px;">
    <div class="card-title" style="color: #D32F2F;">❌ الخطأ الثاني: الدليل التجاري الستاتيكي الجامد (مثل دليل يلوبيجز أو جوجل ماب)</div>
    <p><strong>لماذا لا ينجح الدليل الثابت؟</strong></p>
    <p>
      لأن قات اليوم ليس كقات الأمس! عرض متجر يحمل صورة قديمة لا يفيد الزبون بشيء؛ فالزبون يسأل: <em>"ماذا وصلك اليوم؟ وبكم؟ وهل ما زال متوفراً؟"</em>.
    </p>
    <p style="margin: 0; color: #1B5E20; font-weight: 700;">
      ✔️ الحل الاستراتيجي في قطفة: مفهوم <strong>"القطفة اليومية الحية" (Daily Drops)</strong>. كل يوم يحمل عروضه الخاصة، وإذا لم ينشر التاجر بضاعته يظهر متجره بحالة <em>"لم تصل بضاعة اليوم بعد"</em>.
    </p>
  </div>

  <div class="card" style="margin-bottom: 12px;">
    <div class="card-title" style="color: #D32F2F;">❌ الخطأ الثالث: بناء نظام دردشة داخلية معقد (In-App Chat) واستخدام خرائط جوجل المدفوعة</div>
    <ul>
      <li><strong>الدردشة الداخلية:</strong> المقاوتي في السوق يقف تحت الضغط ولديه بضع ساعات لإنهاء بضاعته؛ لن يفتح شات مكتوب داخل تطبيق جديد، بينما يستخدم تطبيق WhatsApp يومياً بطلاقة ويفضل المكالمة الصوتية المباشرة. لذلك جعلنا التواصل عبر زر اتصال مباشر وزر WhatsApp مجهز بالرسالة.</li>
      <li><strong>خرائط جوجل المدفوعة:</strong> أسعار Google Maps API مرتفعة بالدولار وتستنزف الميزانية، بالإضافة إلى أن أسواق القات الشعبية ومفارشها غير مرقمة على خرائط جوجل. استبدلناها بـ <strong>"الدليل الجغرافي الهرمي بالمعالم المحلية"</strong> (المحافظة > المديرية > السوق > أقرب معلم بارز) وهو أدق 100 مرة للزبون اليمني ومجاني تماماً!</li>
    </ul>
  </div>

  <div class="alert-box tip">
    <div class="alert-title">💎 القاعدة الذهبية لمنصة قطفة</div>
    <strong>"بساطة قصوى للمقاوتي في السوق + سرعة خاطفة للزبون + تكلفة تشغيل تقترب من الصفر على إدارة المنصة"</strong>.
  </div>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 4</span>
  </div>
</div>


<!-- ==================== SECTION 3: PRODUCT & PERSONAS ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم الثالث: تجربة المنتج وأطراف المنظومة (User Personas)</span>
    <span class="section-num">03</span>
  </h1>

  <h2 class="subsection-title">1. شخصيات المستخدمين واحتياجاتهم الحقيقية</h2>

  <div class="grid-3">
    <!-- Persona 1 -->
    <div class="card featured">
      <div style="background: #E8F5E9; color: #1B5E20; font-weight: 700; padding: 4px 8px; border-radius: 4px; display: inline-block; font-size: 11px; margin-bottom: 6px;">التاجر / المقاوتي</div>
      <div class="card-title" style="margin-bottom: 4px;">"العم صالح" (42 سنة)</div>
      <p style="font-size: 11.5px; color: #666; margin-bottom: 8px;">مقاوتي في سوق علي محسن أو سوق نقم</p>
      <ul style="font-size: 11.5px; padding-right: 15px; margin: 0;">
        <li><strong>مستواه التقني:</strong> يستخدم الواتساب وفيسبوك، يكره النماذج المعقدة والكتابة الطويلة.</li>
        <li><strong>أكبر همومه:</strong> تصريف شحنته اليومية بأفضل سعر قبل الساعة الرابعة عصراً.</li>
        <li><strong>ما يقدمه التطبيق له:</strong> رفع صور القات وتحديد السعر والنوع في 30 ثانية فقط، وتلقي الاتصالات فوراً دون أي تعقيد.</li>
      </ul>
    </div>

    <!-- Persona 2 -->
    <div class="card featured">
      <div style="background: #E3F2FD; color: #0D47A1; font-weight: 700; padding: 4px 8px; border-radius: 4px; display: inline-block; font-size: 11px; margin-bottom: 6px;">المشتري اليومي</div>
      <div class="card-title" style="margin-bottom: 4px;">"محمد" (29 سنة)</div>
      <p style="font-size: 11.5px; color: #666; margin-bottom: 8px;">موظف قطاع خاص / شركة اتصالات</p>
      <ul style="font-size: 11.5px; padding-right: 15px; margin: 0;">
        <li><strong>مستواه التقني:</strong> مرتفع، يبحث عن الكفاءة وتوفير الوقت والجهد.</li>
        <li><strong>أكبر همومه:</strong> خروجه من الدوام في ذروة الزحام ولديه 30 دقيقة فقط للشراء قبل بدء المقيل.</li>
        <li><strong>ما يقدمه التطبيق له:</strong> فتح التطبيق أثناء خروجه، رؤية المقاوتية في طريقه، فحص بضاعة اليوم وأسعارها، وحجز حزمته هاتفياً فوراً.</li>
      </ul>
    </div>

    <!-- Persona 3 -->
    <div class="card featured">
      <div style="background: #FFF3E0; color: #E65100; font-weight: 700; padding: 4px 8px; border-radius: 4px; display: inline-block; font-size: 11px; margin-bottom: 6px;">مشتري المناسبات</div>
      <div class="card-title" style="margin-bottom: 4px;">"هشام" (35 سنة)</div>
      <p style="font-size: 11.5px; color: #666; margin-bottom: 8px;">مغترب أو رب أسرة يجهز لعرس أو ضيوف</p>
      <ul style="font-size: 11.5px; padding-right: 15px; margin: 0;">
        <li><strong>مستواه التقني:</strong> متوسط، يدقق في الجودة والسمعة ومستعد لدفع مبالغ عالية.</li>
        <li><strong>أكبر همومه:</strong> الخوف من شراء كميات كبيرة مغشوشة أو غير مناسبة لضيوفه.</li>
        <li><strong>ما يقدمه التطبيق له:</strong> فلترة المتاجر حسب "الأعلى تقييماً"، تصفح صور وآراء المشترين السابقين، والاتفاق مع تاجر موثوق.</li>
      </ul>
    </div>
  </div>

  <h2 class="subsection-title">2. الميزات الجوهرية لتجربة المستخدم</h2>

  <div class="grid-2">
    <div class="card">
      <div class="card-title">🚀 تجربة الزائر الحر وإنهاء تشتت الواتساب</div>
      <p style="font-size: 12px;">
        لا نلزم الزائر بإنشاء حساب للتصفح. يستطيع أي مشتري استعراض عروض أسواق القات في اليمن وصورها الحقيقية وأسعارها ومناطقها في شاشة واحدة منظمة، والتواصل المباشر مع المقاوتي دون الحاجة للاشتراك في عشرات مجموعات الواتساب المزدحمة.
      </p>
    </div>

    <div class="card">
      <div class="card-title">⚡ النشر السريع للمقاوتي (صفر عبء تشغيلي)</div>
      <p style="font-size: 12px;">
        واجهة فائقة البساطة بإبهام اليد الواحدة: تشغيل الكاميرا الحية، التقاط صورة القات، تحديد النوع والسعر، وزر تبديل [متوفر / نفد]. العملية لا تستغرق أكثر من 30 ثانية لتجلب له زبائن جدد دون أي كتابة أو أعباء إدارية تثقل عمله في السوق.
      </p>
    </div>

    <div class="card">
      <div class="card-title">🗺️ خريطة السوق وموقع مفرش المقاوتي</div>
      <p style="font-size: 12px;">
        خريطة تفاعلية خفيفة لأسواق القات في اليمن توضح موقع مفرش التاجر بدقة مع علامات ملونة [أخضر: متوفر الآن / رمادي: نفد]. تتيح للمشتري التوجه لمفرش المقاوتي مباشرة في السوق دون تيه في الأزقة والزحام.
      </p>
    </div>

    <div class="card">
      <div class="card-title">🛡️ ثقة المشتري: توثيق الأرقام ومكافحة التضليل</div>
      <p style="font-size: 12px;">
        توثيق إلزامي لأرقام المقاوتية برمز OTP لمنع الحسابات الوهمية، مع شارة "رقم موثق". وتوفير زر سريع للإبلاغ عن أي عرض مضلل أو صورة غير حقيقية، مع تجميد آلي للعرض بعد 3 بلاغات لحماية مصداقية المنصة.
      </p>
    </div>

    <div class="card">
      <div class="card-title">📞 التحويل الفوري والتسويق المستمر (Deep Linking)</div>
      <p style="font-size: 12px;">
        زر اتصال هاتفي وزر WhatsApp مجهز برسالة الطلب. وإمكانية مشاركة بطاقة العرض المصورة على حالات الواتساب ومنصات التواصل برابط مباشر ذكي يفتح العرض المخصص فوراً داخل تطبيق «قطفة».
      </p>
    </div>

    <div class="card">
      <div class="card-title">⏱️ العروض المتجددة ووقت التحديث اللحظي</div>
      <p style="font-size: 12px;">
        إظهار توقيت التحديث بدقة بالغة (مثال: *"تم التحديث قبل 8 دقائق"*) لتأكيد طزاجة القات، مع سرعة فتح للتطبيق في أقل من 1.5 ثانية واستهلاك اقتصادي جداً لباقة الإنترنت.
      </p>
    </div>
  </div>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 5</span>
  </div>
</div>


<!-- ==================== SECTION 4: MVP SCOPE ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم الرابع: نطاق النسخة الأولى (MVP Scope)</span>
    <span class="section-num">04</span>
  </h1>

  <div class="alert-box info">
    <div class="alert-title">🎯 تعريف الـ MVP (المنتج ذو الحد الأدنى القابل للحياة)</div>
    هو أبسط وأسرع وأقوى نسخة من التطبيق تحقق الهدف التجاري وتحل المشكلة الأساسية دون أي زوائد برمجية تستهلك الوقت والميزانية دون عائد ملموس.
  </div>

  <h2 class="subsection-title">1. مكونات المنظومة في المرحلة الأولى</h2>

  <div class="grid-3">
    <div class="card featured">
      <div class="card-title">1. تطبيق الموبايل (Android & iOS)</div>
      <ul style="font-size: 11.5px; padding-right: 15px; margin: 0;">
        <li>تصفح كامل كضيف ينهي تشتت مجموعات الواتساب.</li>
        <li>خريطة تفاعلية لأسواق القات في اليمن ومواقع المفارش.</li>
        <li>قوائم "القطفة اليومية" بصور حقيقية وأسعار وتوقيت التحديث.</li>
        <li>زر فوري لحالة البضاعة [متوفر / نفد].</li>
        <li>زري الاتصال الهاتفي ومحادثة WhatsApp المباشرة.</li>
        <li>توثيق أرقام البائعين وشارة "رقم موثق".</li>
        <li>زر الإبلاغ الفوري عن العروض المضللة.</li>
        <li>المشاركة الذكية بروابط مباشرة (Deep Linking).</li>
        <li>سرعة فتح فائقة وخفة تامة في استهلاك باقة الإنترنت.</li>
      </ul>
    </div>

    <div class="card featured">
      <div class="card-title">2. واجهة المقاوتي الذكية</div>
      <ul style="font-size: 11.5px; padding-right: 15px; margin: 0;">
        <li>فائدة فورية بجلب زبائن دون أي عبء تشغيلي.</li>
        <li>تسجيل الحساب وتوثيق رقم الهاتف برمز OTP.</li>
        <li>صفحة المتجر وموقعه على خريطة السوق.</li>
        <li>زر النشر السريع للقطفة في 30 ثانية بالكاميرا.</li>
        <li>زر التبديل السريع لحالة البضاعة [متوفر / نفد].</li>
        <li>تعديل الأسعار بالريال والوحدة وتوليد رابط التسويق.</li>
      </ul>
    </div>

    <div class="card featured">
      <div class="card-title">3. لوحة الإدارة والتحكم (Web Admin)</div>
      <ul style="font-size: 11.5px; padding-right: 15px; margin: 0;">
        <li>مراجعة واعتماد المتاجر وتوثيق أرقام الهواتف.</li>
        <li>طابور مراجعة ومعالجة بلاغات العروض المضللة.</li>
        <li>إدارة خريطة أسواق القات في عموم محافظات اليمن.</li>
        <li>لوحة مؤشرات سريعة لحجم النشاط والزيارات والاتصالات.</li>
        <li>أدوات حظر المحتوى أو المتاجر المخالفة فوراً.</li>
      </ul>
    </div>
  </div>

  <h2 class="subsection-title">2. جدول القرارات الذكية: ما تم اعتماده مقابل ما تم تأجيله</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 25%;">الميزة أو التقنية</th>
        <th style="width: 20%;">القرار في MVP</th>
        <th style="width: 55%;">السبب والبديل المعتمد</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">خريطة السوق وموقع المفرش</td>
        <td><span class="badge success">معتمدة في MVP</span></td>
        <td><strong>الحل المعتمد:</strong> خريطة OpenStreetMap التفاعلية المجانية + مخطط مفارش السوق، توفر خريطة واضحة لمفارش المقاوتية بصفر تكلفة API.</td>
      </tr>
      <tr>
        <td class="highlight">بوابة الدفع الإلكتروني</td>
        <td><span class="badge warning">مؤجلة للمرحلة 3</span></td>
        <td><strong>البديل:</strong> الدفع نقداً باليد. 85% من التعاملات كاش، وتجنبنا تعقيدات الحسابات البنكية والتراخيص.</td>
      </tr>
      <tr>
        <td class="highlight">أسطول التوصيل والتتبع الحي</td>
        <td><span class="badge warning">مؤجلة للمرحلة 3</span></td>
        <td><strong>البديل:</strong> استلام الزبون بنفسه أو ترتيب خاص مع التاجر. تجنبنا التكاليف الباهظة للسيارات والدبابات وتلف السلعة في الزحام.</td>
      </tr>
      <tr>
        <td class="highlight">الدردشة الكتابية داخل التطبيق</td>
        <td><span class="badge warning">مؤجلة للمرحلة 2</span></td>
        <td><strong>البديل:</strong> زر اتصال مباشر وزر WhatsApp. أسهل للتاجر وأرخص تشغيلياً وأكثر اعتياداً للشارع اليمني.</td>
      </tr>
      <tr>
        <td class="highlight">خرائط جوجل Google Maps المدفوعة</td>
        <td><span class="badge neutral">مستبعدة لتكلفتها</span></td>
        <td><strong>البديل:</strong> خريطة OpenStreetMap + الدليل الهرمي بالمعالم. خرائط جوجل باهظة ولا ترقم أزقة الأسواق الشعبية.</td>
      </tr>
      <tr>
        <td class="highlight">البث المباشر المدمج (Live)</td>
        <td><span class="badge warning">مؤجلة للمرحلة 4</span></td>
        <td><strong>البديل:</strong> صور حقيقية ملتقطة مباشرة وفيديوهات 10 ثوانٍ. سرعات الإنترنت وتكاليف الخوادم لا تسمح بالبث الحي حالياً.</td>
      </tr>
      <tr>
        <td class="highlight">فحص الجودة بالذكاء الاصطناعي</td>
        <td><span class="badge warning">مؤجلة للمرحلة 4</span></td>
        <td><strong>البديل:</strong> الرقابة المجتمعية بالبلاغات. استخدام AI في مرحلة البداية ترف مالي غير مبرر تجارياً (Over-engineering).</td>
      </tr>
    </tbody>
  </table>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 6</span>
  </div>
</div>


<!-- ==================== SECTION 5: BUSINESS MODEL & MONETIZATION ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم الخامس: نموذج العمل واستراتيجية الأرباح (Monetization)</span>
    <span class="section-num">05</span>
  </h1>

  <h2 class="subsection-title">1. التدرج المدروس لتحقيق الإيرادات عبر 3 مراحل</h2>
  <p>
    لضمان عدم نفور التجار وبناء شبكة عملاقة وسريعة، تم توزيع استراتيجية الدخل وفق المراحل التالية:
  </p>

  <div class="grid-3">
    <div class="card">
      <div style="font-weight: 800; color: #1B5E20; margin-bottom: 5px;">المرحلة الأولى: النمو المجاني 0%</div>
      <div class="badge neutral" style="margin-bottom: 8px;">الأشهر الأولى (MVP)</div>
      <p style="font-size: 11.5px;">
        <strong>الهدف:</strong> كسر حاجز التردد واحتلال السوق.<br>
        فتح المتاجر ورفع القطفات والتصفح مجاني 100% بدون أي رسوم أو عمولات لجذب أكبر عدد من المقاوتية وبناء قاعدة البيانات.
      </p>
    </div>

    <div class="card featured">
      <div style="font-weight: 800; color: #E65100; margin-bottom: 5px;">المرحلة الثانية: الاشتراكات والتمييز</div>
      <div class="badge success" style="margin-bottom: 8px;">بعد استقرار المنصة</div>
      <p style="font-size: 11.5px;">
        <strong>1. باقة "المقاوتي المعتمد":</strong> اشتراك شهري رمزي (15,000 إلى 25,000 ريال = 25$ تقريباً) يمنحه شارة التوثيق وأولوية الظهور.<br>
        <strong>2. تثبيت القطفة في الصدارة:</strong> رسوم يومية رمزية لتثبيت العرض أعلى نتائج الحي وقت الذروة.<br>
        <strong>3. إشعارات الحي الموجهة:</strong> إرسال إشعار فوري لسكان الحي بوصول بضاعة خاصة.
      </p>
    </div>

    <div class="card">
      <div style="font-weight: 800; color: #0D47A1; margin-bottom: 5px;">المرحلة الثالثة: الرعايات والعمولات</div>
      <div class="badge warning" style="margin-bottom: 8px;">التوسع الشامل</div>
      <p style="font-size: 11.5px;">
        <strong>1. إعلانات الشركات الشريكة:</strong> مساحات إعلانية لشركات الطاقة الشمسية ومضخات الري وسيارات التبريد وتجارة المستلزمات.<br>
        <strong>2. عمولات المعاملات B2B:</strong> نسبة متناهية الصغر (1% إلى 2%) عند تفعيل العربون الإلكتروني وصفقات الجملة بين المزارع والمقاوتية.
      </p>
    </div>
  </div>

  <h2 class="subsection-title">2. تحليل نقطة التعادل المالي (Breakeven Analysis)</h2>
  <p>
    بفضل التكلفة التشغيلية فائقة الانخفاض التي صممناها، فإن نقطة التعادل للمشروع سهلة التحقيق بدرجة غير مسبوقة:
  </p>

  <div class="alert-box tip">
    <div class="alert-title">📊 معادلة نقطة التعادل (الأرقام تتحدث)</div>
    إذا كانت تكلفة تشغيل الخوادم والرسائل والتقنية بالكامل قرابة <strong>75$ إلى 80$ شهرياً</strong>، وقيمة اشتراك التاجر المعتمد هي <strong>20$ إلى 25$ شهرياً</strong>:<br>
    👉 <strong>اشتراك 4 مقاوتية فقط</strong> في كل أسواق اليمن يغطي 100% من فواتير استضافة وتشغيل المنصة بالكامل!<br>
    👉 أي اشتراك خامس فما فوق هو <strong>صافي ربح وتدفق نقدي إيجابي</strong> يدخل خزينة المشروع.
  </div>

  <h2 class="subsection-title">3. توقعات التدفق المالي التقديري (Financial Projections)</h2>
  <table>
    <thead>
      <tr>
        <th>المرحلة الزمنية</th>
        <th>عدد المتاجر النشطة</th>
        <th>المتاجر المشتركة في الباقات</th>
        <th>الإيراد الشهري المقدر</th>
        <th>التكلفة التشغيلية (تقنية)</th>
        <th>صافي الفائض التشغيلي</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">نهاية الشهر 3 (إطلاق MVP)</td>
        <td>150 متجر</td>
        <td>مجاني (فترة تجريبية)</td>
        <td>0 $</td>
        <td>~60 $</td>
        <td>(60 $) استثمار أولي</td>
      </tr>
      <tr>
        <td class="highlight">نهاية الشهر 6 (بدء الاشتراكات)</td>
        <td>400 متجر</td>
        <td>50 متجر مشترك (25$)</td>
        <td><strong>1,250 $ شهرياً</strong></td>
        <td>~80 $</td>
        <td><strong>+ 1,170 $ شهرياً</strong></td>
      </tr>
      <tr>
        <td class="highlight">نهاية العام الأول (12 شهراً)</td>
        <td>1,000 متجر</td>
        <td>250 متجر + إعلانات</td>
        <td><strong>6,250 $ شهرياً</strong></td>
        <td>~150 $</td>
        <td><strong>+ 6,100 $ شهرياً</strong></td>
      </tr>
      <tr>
        <td class="highlight">نهاية العام الثاني (24 شهراً)</td>
        <td>3,500 متجر في 5 محافظات</td>
        <td>900 متجر + إعلانات شركات</td>
        <td><strong>25,000 $ شهرياً</strong></td>
        <td>~450 $</td>
        <td><strong>+ 24,550 $ شهرياً</strong></td>
      </tr>
    </tbody>
  </table>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 7</span>
  </div>
</div>


<!-- ==================== SECTION 6: FIELD OPERATIONS ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم السادس: التسويق الميداني والاستحواذ على التجار</span>
    <span class="section-num">06</span>
  </h1>

  <div class="alert-box warning">
    <div class="alert-title">🎯 حقيقة تسويقية حاسمة</div>
    منصة قطفة هي سوق ذو طرفين يقوده جانب العرض (Supply-driven Marketplace). هذا يعني ببساطة: <strong>"إذا تواجد المقاوتية الممتازون وعُرضت البضاعة الطازجة يومياً، سيأتي الزبائن تلقائياً كالبرق دون الحاجة لميزانيات إعلانية ضخمة"</strong>.
  </div>

  <h2 class="subsection-title">1. استراتيجية النزول الميداني: فريق "سفراء قطفة"</h2>
  <p>
    المقاوتي رجل عملي يقضي يومه في المفرش، ولن يقوم بتنزيل تطبيق بمفرده لمجرد رؤية إعلان على فيسبوك. لذلك يعتمد الإطلاق على <strong>النزول البشري الميداني</strong>:
  </p>

  <div class="grid-3">
    <div class="card">
      <div class="card-title">1. سفيران ميدانيان</div>
      <p style="font-size: 11.5px; margin: 0;">
        شابان لبقان ونشيطان من أبناء المنطقة يتمتعان بعلاقات جيدة في أشهر أسواق صنعاء (سوق علي محسن، سوق نقم، سوق شميلة).
      </p>
    </div>
    <div class="card">
      <div class="card-title">2. تدريب 5 دقائق في المفرش</div>
      <p style="font-size: 11.5px; margin: 0;">
        يقف السفير مع المقاوتي أو مساعده الشاب، ويفتح معه المتجر، ويلتقط صورة مفرشه، ويدربه على نشر أول قطفة خلال 60 ثانية.
      </p>
    </div>
    <div class="card">
      <div class="card-title">3. استيكر ولافتة المتجر</div>
      <p style="font-size: 11.5px; margin: 0;">
        تسليم التاجر ملصقاً أنيقاً يوضع على مفرشه يحتوي على QR Code: <em>"تابع قطفة اليوم الطازجة وقيمنا على تطبيق قطفة"</em>.
      </p>
    </div>
  </div>

  <h2 class="subsection-title">2. حملة "أول 100 مقاوتي رائد" (Founding Merchants)</h2>
  <ul>
    <li><strong>شارة الرواد الدائمة:</strong> منح أول 100 تاجر ينضمون للمنصة شارة توثيق مجانية مدى الحياة، ومعاملتهم كشركاء نجاح.</li>
    <li><strong>تصوير احترافي مجاني:</strong> يقوم فريق المنصة بالتقاط صور عالية الجودة لمفارشهم وأنواع القات الفاخر لديهم، مما يشعر التاجر بالفخر والتميز أمام زملائه في السوق.</li>
    <li><strong>أثر الغيرة الإيجابية بين التجار:</strong> عندما يرى المقاوتي في المفرش المجاور زميله يرفع هاتفه ويلتقط صورة القطفة، وتأتيه اتصالات زبائن جدد، سيسأل تلقائياً: <em>"ما هذا التطبيق؟ سجّلوا لي متجراً معكم!"</em>.</li>
  </ul>

  <h2 class="subsection-title">3. استراتيجية النمو الفيروسي بين المستهلكين (B2C Viral Loop)</h2>

  <div class="grid-2">
    <div class="card">
      <div class="card-title">📲 بطاقة القطفة المصورة عبر WhatsApp</div>
      <p style="font-size: 12px;">
        الواتساب هو شريان الحياة في اليمن. أضفنا زراً يتيح للمشتري أو التاجر مشاركة بطاقة القطفة المصورة بضغطة واحدة، فتصل في مجموعات الواتساب والمقايل متضمنة صورة القات وسعره ورابط فتحه بالتطبيق. هذا الزر وحده كفيل بجلب آلاف المستخدمين مجاناً.
      </p>
    </div>

    <div class="card">
      <div class="card-title">🎭 المحتوى الفكاهي والتراثي عبر TikTok وفيسبوك</div>
      <p style="font-size: 12px;">
        ثقافة المقيل والقات في اليمن غنية بالطرائف والنقاشات اليومية. سنطلق مقاطع فيديو قصيرة فكاهية تناقش مواقف شراء القات المعتادة: (المشتري الذي ينتهي دوامه ويتورط في الزحام، أو من يشتري قاتاً مغشوشاً)، مع تقديم تطبيق قطفة كالحل السحري العصري.
      </p>
    </div>
  </div>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 8</span>
  </div>
</div>


<!-- ==================== SECTION 7: BUDGET & COSTS ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم السابع: الميزانية الواقعية والتكاليف الاستثمارية</span>
    <span class="section-num">07</span>
  </h1>

  <h2 class="subsection-title">1. التكاليف التأسيسية للتطوير لمرة واحدة (CapEx)</h2>
  <p>
    تكلفة بناء المنصة بالكامل بأعلى المعايير الهندسية المؤسسية وتسليم كود مصدري نقي مملوك بالكامل لصاحب المشروع:
  </p>

  <table>
    <thead>
      <tr>
        <th style="width: 35%;">البند ومجال العمل</th>
        <th style="width: 20%;">التكلفة التقديرية ($)</th>
        <th style="width: 45%;">ما الذي يشمله هذا البند؟</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">تصميم واجهة وتجربة المستخدم (UI/UX)</td>
        <td>$800 - $1,200</td>
        <td>تصميم كافة الشاشات على Figma، نظام الألوان، وهوية التطبيق التراثية.</td>
      </tr>
      <tr>
        <td class="highlight">برمجة تطبيق الموبايل (Flutter)</td>
        <td>$2,200 - $3,500</td>
        <td>بناء نسختي Android و iOS مع وضع التصفح كضيف ودعم العمل دون إنترنت.</td>
      </tr>
      <tr>
        <td class="highlight">برمجة الخادم وقاعدة البيانات (Backend)</td>
        <td>$1,800 - $2,800</td>
        <td>بناء محرك البحث، واجهات الـ API، الحماية، الفهرسة، وتكامل الرسائل.</td>
      </tr>
      <tr>
        <td class="highlight">لوحة التحكم والإدارة (Admin Web)</td>
        <td>$900 - $1,400</td>
        <td>واجهة ويب سريعة لاعتماد المتاجر والتوثيق والرقابة والإحصائيات.</td>
      </tr>
      <tr>
        <td class="highlight">اختبارات الجودة وضمان الأداء (QA)</td>
        <td>$500 - $800</td>
        <td>فحص التطبيق على شبكات 3G اليمنية وأجهزة أندرويد الاقتصادية الضعيفة.</td>
      </tr>
      <tr>
        <td class="highlight">حسابات المطورين والنطاق الرسمي</td>
        <td>$140 - $185</td>
        <td>Google Play ($25) + Apple Developer ($99 سنوياً) + نطاق qatfa.ye أو com.</td>
      </tr>
      <tr style="background-color: #E8F5E9; font-weight: 700;">
        <td style="color: #1B5E20; font-size: 13px;">المجموع الإجمالي للتأسيس (CapEx)</td>
        <td style="color: #1B5E20; font-size: 13px;">$6,340 - $9,885</td>
        <td style="color: #1B5E20; font-size: 11.5px;">منظومة مؤسسية متكاملة وجاهزة للإطلاق الميداني الفوري.</td>
      </tr>
    </tbody>
  </table>

  <h2 class="subsection-title">2. التكاليف التشغيلية الشهرية (OpEx - التقنية والاستضافة)</h2>
  <p>
    كيف نجحنا في جعل تشغيل المنصة يكلف <strong>أقل من 80 دولار شهرياً</strong> لخدمة ما يصل إلى 25,000 مستخدم و 500 متجر؟
  </p>

  <table>
    <thead>
      <tr>
        <th>الخدمة السحابية</th>
        <th>المزود المعتمد</th>
        <th>التكلفة الشهرية ($)</th>
        <th>سر انخفاض التكلفة والكفاءة</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">الخادم الرئيسي وقاعدة البيانات</td>
        <td>Hetzner Cloud (ألمانيا)</td>
        <td><strong>$16.00</strong></td>
        <td>خادم عالي القوة (8GB RAM) بتكلفة ثابتة بدلاً من سحابة AWS الباهظة.</td>
      </tr>
      <tr>
        <td class="highlight">تخزين وسائط وصور القات</td>
        <td>Cloudflare R2</td>
        <td><strong>$2.00 - $5.00</strong></td>
        <td>أول 10GB مجاناً، ورسوم نقل وتنزيل الصور للزبائن 0.00$ مجاناً مدى الحياة!</td>
      </tr>
      <tr>
        <td class="highlight">حماية السيرفرات وتسريع النت</td>
        <td>Cloudflare WAF / CDN</td>
        <td><strong>$0.00</strong></td>
        <td>الباقة المجانية توفر حماية كاملة من الاختراق وشهادات أمان SSL غير محدودة.</td>
      </tr>
      <tr>
        <td class="highlight">خدمة الإشعارات اللحظية</td>
        <td>Firebase (Google)</td>
        <td><strong>$0.00</strong></td>
        <td>خدمة إرسال إشعارات غير محدودة مجانية 100% من شركة Google.</td>
      </tr>
      <tr>
        <td class="highlight">رسائل التحقق OTP برقم الهاتف</td>
        <td>بوابة SMS محلية / WhatsApp</td>
        <td><strong>$35.00 - $50.00</strong></td>
        <td>تكلفة إرسال أكواد التحقق للمستخدمين الجدد مع حماية صارمة لمنع الاستنزاف.</td>
      </tr>
      <tr>
        <td class="highlight">النسخ الاحتياطي اليومي المشفر</td>
        <td>R2 Cloud Backup</td>
        <td><strong>$1.00</strong></td>
        <td>حفظ نسخ احتياطية يومية من قاعدة البيانات لضمان أمان البيانات التام.</td>
      </tr>
      <tr style="background-color: #FFF3E0; font-weight: 700;">
        <td style="color: #E65100; font-size: 13px;">إجمالي الفاتورة التقنية الشهرية</td>
        <td style="color: #E65100;">—</td>
        <td style="color: #E65100; font-size: 13px;">$54 - $72 / شهرياً</td>
        <td style="color: #E65100; font-size: 11.5px;">أقل من 80$ شهرياً لتشغيل البنية التحتية بالكامل دون أي هدر!</td>
      </tr>
    </tbody>
  </table>

  <div class="alert-box tip">
    <div class="alert-title">💡 دلالة هذه الأرقام لصاحب المشروع</div>
    هذه الأرقام تمنحك <strong>أماناً مالياً مطلقاً (Infinite Runway)</strong>؛ حيث يمكن للمشروع أن يعمل لمدة عام كامل بميزانية استضافة تشغيلية لا تتجاوز 1,000 دولار، دون أي ضغط مالي، حتى تنمو قاعدة التجار المشتركين وتغطي التكاليف وتفيض.
  </div>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 9</span>
  </div>
</div>


<!-- ==================== SECTION 8: RISK MANAGEMENT ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم الثامن: إدارة المخاطر وسياسات Google Play</span>
    <span class="section-num">08</span>
  </h1>

  <h2 class="subsection-title">1. استراتيجية اجتياز مراجعة متجر Google Play</h2>
  <div class="alert-box warning">
    <div class="alert-title">⚖️ الوضع التنظيمي لنبتة القات</div>
    القات سلعة زراعية وتجارية قانونية 100% داخل أراضي الجمهورية اليمنية وتخضع لرسوم ضريبية رسمية، لكن خوارزميات الفحص الآلي في متجر Google Play قد تصنف النبتة بشكل خاطئ إذا لم يتم صياغة الملف بحذر شديد.
  </div>

  <p><strong>الإجراءات العملية الأربعة المعتمدة للنشر في Google Play:</strong></p>
  <div class="grid-2">
    <div class="card">
      <div class="card-title">1. التقييد الجغرافي الصارم لليمن فقط</div>
      <p style="font-size: 12px;">
        حصر توفر التطبيق في إعدادات Google Play Console على "الجمهورية اليمنية" فقط. هذا يمنع خضوع التطبيق لقوانين الدول الأخرى ويثبت امتثاله للقوانين المحلية السارية في اليمن.
      </p>
    </div>

    <div class="card">
      <div class="card-title">2. الصياغة الزراعية المهنية</div>
      <p style="font-size: 12px;">
        تصنيف التطبيق في فئة "الأعمال والتسوق"، واستخدام وصف مهني رصين: <em>"منصة إلكترونية ودليل تجاري للمنتجات الزراعية والمحاصيل التراثية والأسواق الشعبية في الجمهورية اليمنية"</em>، وتجنب الكلمات التي تثير روبوتات الفحص الآلي.
      </p>
    </div>

    <div class="card">
      <div class="card-title">3. التصنيف العمري المرتفع (+18)</div>
      <p style="font-size: 12px;">
        تحديد الفئة العمرية للتطبيق لمن هم فوق 18 عاماً في استبيان المحتوى الدولي (IARC)، لضمان عدم وجود أي شبهة متعلقة بحماية الأطفال أو المراهقين.
      </p>
    </div>

    <div class="card">
      <div class="card-title">4. عدم معالجة مدفوعات داخل التطبيق</div>
      <p style="font-size: 12px;">
        كون التطبيق في مرحلة MVP يعمل كدليل معلومات واستكشاف وتواصل مباشر ولا يعالج مدفوعات رقمية لمواد زراعية، يرفع نسبة القبول في المتجر إلى أعلى درجة ممكنة.
      </p>
    </div>
  </div>

  <h2 class="subsection-title">2. شبكة التوزيع الموازي في اليمن (تأمين المشروع 100%)</h2>
  <p>
    كعادة كبرى التطبيقات اليمنية الرائدة (تطبيق بنك الكريمي، تطبيق يمن موبايل، وتطبيق يو YOU)، لا نعتمد حصراً على متجر جوجل؛ بل نوفر قنوات تنزيل موازية تضمن وصول التطبيق لكل مواطن حتى لو تعطل متجر جوجل:
  </p>
  <ul>
    <li><strong>رابط تنزيل APK مباشر وسريع:</strong> من الموقع الرسمي <code>qatfa.ye/download</code> عبر خوادم سحابية فائقة السرعة بضغطة زر واحدة.</li>
    <li><strong>قناة Telegram الرسمية الموثقة:</strong> رفع ملف التحديثات والـ APK في القناة الرسمية؛ حيث يعتبر تيليجرام المنصة المفضلة لتنزيل التطبيقات في اليمن دون استهلاك رصيد كبير.</li>
    <li><strong>متجر Huawei AppGallery:</strong> نشر التطبيق على متجر هواوي الرسمي المنتشر بكثافة على هواتف Honor و Huawei في السوق اليمني والذي يتميز بمرونة كبيرة مع التطبيقات المحلية.</li>
  </ul>

  <h2 class="subsection-title">3. مصفوفة المخاطر التشغيلية الأخرى وخطط احتوائها</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 20%;">نوع الخطر</th>
        <th style="width: 35%;">طبيعة الخطر وتأثيره</th>
        <th style="width: 45%;">خطة المواجهة والحل الاستباقي</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">ضعف الإنترنت 3G</td>
        <td>صعوبة تصفح الصور وثقل التطبيق لدى المستخدم.</td>
        <td>ضغط الصور إلى أحجام بالغة الصغر (70KB) بصيغة WebP، وتفعيل التخزين المؤقت ليعمل التطبيق حتى دون اتصال.</td>
      </tr>
      <tr>
        <td class="highlight">التضليل والأسعار الوهمية</td>
        <td>قيام مقاوتي بعرض صورة قديمة أو سعر غير حقيقي.</td>
        <td>تفعيل الرقابة المجتمعية بالبلاغات، وتعليق الحساب عند 3 بلاغات، وإظهار شارة التوثيق للتجار الصادقين فقط.</td>
      </tr>
      <tr>
        <td class="highlight">تردد كبار التجار</td>
        <td>انشغال المقاوتي وعدم اهتمامه بالتكنولوجيا.</td>
        <td>تدريب المساعد الشاب للتاجر في المفرش، وتبسيط واجهة النشر لتستغرق نقرة واحدة وصورة سريعة بالكاميرا.</td>
      </tr>
    </tbody>
  </table>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 10</span>
  </div>
</div>


<!-- ==================== SECTION 9: TIMELINE & NEXT STEPS ==================== -->
<div class="page-break">
  <h1 class="section-title">
    <span>القسم التاسع: الجدول الزمني للإطلاق والخطوات الفورية</span>
    <span class="section-num">09</span>
  </h1>

  <h2 class="subsection-title">1. خطة الـ 10 أسابيع حتى الإطلاق التجاري الميداني</h2>
  <p>
    تم تقسيم العمل التنفيذي إلى <strong>5 مراحل (Sprints)</strong> مدة كل مرحلة أسبوعان، للوصول إلى السوق بأسرع وقت ممكن:
  </p>

  <div class="timeline-step">
    <h4>المرحلة الأولى: التصميم المعماري وهندسة النظام (الأسبوع 1 - 2)</h4>
    <p style="font-size: 11.5px; margin: 0;">
      اعتماد تصاميم شاشات الموبايل ولوحة التحكم على Figma، إعداد الخوادم، تهيئة قواعد البيانات، وبناء نظام التحقق برقم الهاتف (OTP).
    </p>
  </div>

  <div class="timeline-step">
    <h4>المرحلة الثانية: بناء محرك المتاجر والقطفة اليومية والوسائط (الأسبوع 3 - 4)</h4>
    <p style="font-size: 11.5px; margin: 0;">
      برمجة واجهة المقاوتي والنشر السريع بالكاميرا، ضغط ورفع الصور إلى السحابة، وبناء الدليل الجغرافي للأسواق الشعبية في صنعاء وعدن.
    </p>
  </div>

  <div class="timeline-step">
    <h4>المرحلة الثالثة: التفاعل وتوليد الاتصالات والمتابعة (الأسبوع 5 - 6)</h4>
    <p style="font-size: 11.5px; margin: 0;">
      تفعيل زري الاتصال الهاتفي ورسالة الواتساب المجهزة، نظام التقييمات والمراجعات، ومحرك البحث والفلترة حسب النوع والسعر.
    </p>
  </div>

  <div class="timeline-step">
    <h4>المرحلة الرابعة: الإشعارات وفحوصات الشبكة اليمنية والأمان (الأسبوع 7 - 8)</h4>
    <p style="font-size: 11.5px; margin: 0;">
      إطلاق إشعارات Firebase فور نزول القطفة للمتابعين، واختبار تجاوب وسرعة التطبيق ميدانياً على شبكات 3G وباقات يمن موبايل و يو.
    </p>
  </div>

  <div class="timeline-step">
    <h4>المرحلة الخامسة: الإطلاق التجريبي لـ 20 مقاوتي والتدشين الرسمي (الأسبوع 9 - 10)</h4>
    <p style="font-size: 11.5px; margin: 0;">
      نزول ميداني لتسجيل أول 20 مقاوتي في سوق علي محسن وشميلة، رفع التطبيق على المتاجر وتفعيل روابط التنزيل المباشر وبدء الحملة الإعلانية.
    </p>
  </div>

  <h2 class="subsection-title">2. خارطة طريق التوسع المستقبلي عبر 24 شهراً</h2>
  <table>
    <thead>
      <tr>
        <th>المرحلة</th>
        <th>المدى الزمني</th>
        <th>الهدف الاستراتيجي والميزات الكبرى</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="highlight">المرحلة 1: MVP</td>
        <td>الأشهر 0 - 3</td>
        <td>إثبات حاجة السوق، الاستكشاف اليومي، والاتصال المباشر في صنعاء وعدن.</td>
      </tr>
      <tr>
        <td class="highlight">المرحلة 2: التدفق النقدي</td>
        <td>الأشهر 4 - 8</td>
        <td>إطلاق باقات المقاوتي المعتمد، الإعلانات المميزة، وإشعارات الحي، وقصص القطفة القصيرة (Stories).</td>
      </tr>
      <tr>
        <td class="highlight">المرحلة 3: المعاملات والتوصيل</td>
        <td>الأشهر 9 - 15</td>
        <td>نظام حجز القطفة بالعربون، ربط المحافظ الإلكترونية (كريمي، فلوسك، ون كاش، جيب)، وشبكة سائقي الدراجات النارية.</td>
      </tr>
      <tr>
        <td class="highlight">المرحلة 4: سوق الجملة B2B</td>
        <td>الأشهر 16 - 24</td>
        <td>رقمنة سلاسل الإمداد وربط المزارع في همدان ورداع وصعدة مباشرة مع المقاوتية في المدن، ومؤشر الأسعار الذكي.</td>
      </tr>
    </tbody>
  </table>

  <h2 class="subsection-title">3. الخطوات الفورية المطلوبة من صاحب المشروع للبدء الآن</h2>
  <div class="card featured" style="background-color: #F8FAF9;">
    <ol style="margin: 0; padding-right: 20px; font-size: 12.5px;">
      <li style="margin-bottom: 8px;"><strong>اعتماد هذه الوثيقة التوجيهية رسمياً:</strong> كمرجع نهائي لنطاق العمل والميزانية.</li>
      <li style="margin-bottom: 8px;"><strong>إطلاق ورشة التصميم (Sprint 1):</strong> البدء الفوري في تصميم واجهات المستخدم وهوية التطبيق.</li>
      <li style="margin-bottom: 8px;"><strong>حجز النطاق الرسمي وحسابات المطورين:</strong> شراء نطاق <code>qatfa.ye</code> أو <code>qatfa-app.com</code> وفتح حساب Google Play Console.</li>
      <li style="margin-bottom: 0;"><strong>تحديد مسؤولي النزول الميداني:</strong> تسمية سفيرين ميدانيين لبدء حصر وتصوير أوائل المقاوتية المستهدفين في صنعاء تمهيداً للإطلاق التجريبي.</li>
    </ol>
  </div>

  <div class="doc-footer">
    <span>منصة قطفة - الدليل التنفيذي الشامل</span>
    <span>صفحة 11</span>
  </div>
</div>

</body>
</html>
"""

def generate_pdf():
    workspace_dir = os.path.dirname(os.path.abspath(__file__))
    html_file = os.path.join(workspace_dir, "qtfh_founder_summary.html")
    pdf_file = os.path.join(workspace_dir, "qtfh_founder_summary.pdf")

    print(f"Writing HTML to: {html_file}")
    with open(html_file, "w", encoding="utf-8") as f:
        f.write(html_content)

    edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if not os.path.exists(edge_path):
        print(f"Error: Edge not found at {edge_path}")
        sys.exit(1)

    print(f"Generating PDF using headless Microsoft Edge...")
    cmd = [
        edge_path,
        "--headless",
        "--disable-gpu",
        "--no-pdf-header-footer",
        f"--print-to-pdf={pdf_file}",
        f"file:///{os.path.abspath(html_file)}"
    ]

    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print("Error during PDF generation:", res.stderr)
        sys.exit(res.returncode)

    if os.path.exists(pdf_file) and os.path.getsize(pdf_file) > 0:
        print(f"SUCCESS: PDF generated at: {pdf_file}")
        print(f"File size: {os.path.getsize(pdf_file):,} bytes")
    else:
        print("Error: PDF file was not created or is empty.")
        sys.exit(1)

if __name__ == "__main__":
    generate_pdf()
