import { DataSource } from 'typeorm';
import { AllEntities } from '../index';
import { Governorate } from '../entities/governorate.entity';
import { District } from '../entities/district.entity';
import { Market } from '../entities/market.entity';
import { AppVersion } from '../entities/app-version.entity';
import { Currency, AppUpdateType } from '@qatfa/shared-types';

export async function runDatabaseSeed(dataSource: DataSource) {
  const govRepo = dataSource.getRepository(Governorate);
  const districtRepo = dataSource.getRepository(District);
  const marketRepo = dataSource.getRepository(Market);
  const versionRepo = dataSource.getRepository(AppVersion);

  // 1. بذر المحافظات والأسواق الشعبية لليمن
  const countGov = await govRepo.count();
  if (countGov === 0) {
    // محافظة صنعاء
    const sanaa = await govRepo.save({
      nameAr: "صنعاء (الأمانة)",
      nameEn: "Sanaa",
      defaultCurrency: Currency.YER_OLD,
      isActive: true,
    });

    const sabain = await districtRepo.save({
      governorateId: sanaa.id,
      nameAr: "مديرية السبعين",
      nameEn: "Al-Sabain",
      isActive: true,
    });

    const moeain = await districtRepo.save({
      governorateId: sanaa.id,
      nameAr: "مديرية معين",
      nameEn: "Moeen",
      isActive: true,
    });

    await marketRepo.save([
      {
        districtId: sabain.id,
        nameAr: "سوق شميلة الشعبي",
        nameEn: "Shumaila Market",
        centerLatitude: 15.3182,
        centerLongitude: 44.2254,
        isActive: true,
      },
      {
        districtId: moeain.id,
        nameAr: "سوق مذبح وعلي محسن",
        nameEn: "Ali Mohsen Market",
        centerLatitude: 15.3694,
        centerLongitude: 44.1782,
        isActive: true,
      },
    ]);

    // محافظة عدن
    const aden = await govRepo.save({
      nameAr: "عدن",
      nameEn: "Aden",
      defaultCurrency: Currency.YER_NEW,
      isActive: true,
    });

    const sheikh = await districtRepo.save({
      governorateId: aden.id,
      nameAr: "الشيخ عثمان",
      nameEn: "Sheikh Othman",
      isActive: true,
    });

    await marketRepo.save([
      {
        districtId: sheikh.id,
        nameAr: "سوق قات الشيخ عثمان المركزي",
        nameEn: "Sheikh Othman Central Market",
        centerLatitude: 12.8687,
        centerLongitude: 44.9961,
        isActive: true,
      },
    ]);
  }

  // 2. بذر إعدادات الإصدار الافتراضي لموبايل قطفة (وفق ميثاق docs/24 و docs/27)
  const countVersion = await versionRepo.count();
  if (countVersion === 0) {
    await versionRepo.save({
      platform: "android",
      latestVersion: "1.0.0",
      latestBuildNumber: 1,
      minSupportedVersion: "1.0.0",
      minSupportedBuildNumber: 1,
      updateType: AppUpdateType.OPTIONAL,
      title: "مرحباً بك في منصة قطفة 🌿",
      releaseNotes:
        "الإصدار الأول الرسمي - استكشف أسواق القات في صنعاء وعدن وتواصل مع المقاوتية مباشرة.",
      downloadUrl: "https://cdn.qatfa.ye/releases/qatfa-v1.0.0.apk",
      apkSizeInBytes: 15200000,
      sha256:
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      telegramChannelUrl: "https://t.me/qatfa_app",
      telegramPostUrl: "https://t.me/qatfa_app/1",
      playStoreUrl:
        "https://play.google.com/store/apps/details?id=ye.qatfa.app",
      isActive: true,
    });
  }
}
