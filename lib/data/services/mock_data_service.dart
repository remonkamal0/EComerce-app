import '../../domain/models/models.dart';

class MockDataService {
  static List<Category> getCategories() {
    return const [
      // Primary 6 Categories (Mockup 2-column grid)
      Category(
        id: 'refrigerators',
        name: 'Refrigerators',
        group: 'Major Appliances',
        image: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=500&auto=format&fit=crop&q=80',
        iconKey: 'kitchen',
        productCount: 42,
        isPrimary: true,
      ),
      Category(
        id: 'cookers_ovens',
        name: 'Cookers & Ovens',
        group: 'Major Appliances',
        image: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=500&auto=format&fit=crop&q=80',
        iconKey: 'microwave',
        productCount: 38,
        isPrimary: true,
      ),
      Category(
        id: 'water_heaters',
        name: 'Water Heaters',
        group: 'Major Appliances',
        image: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=80',
        iconKey: 'water_drop',
        productCount: 19,
        isPrimary: true,
      ),
      Category(
        id: 'washing_machines',
        name: 'Washing Machines',
        group: 'Major Appliances',
        image: 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=500&auto=format&fit=crop&q=80',
        iconKey: 'local_laundry_service',
        productCount: 31,
        isPrimary: true,
      ),
      Category(
        id: 'air_conditioners',
        name: 'Air Conditioners',
        group: 'Major Appliances',
        image: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=500&auto=format&fit=crop&q=80',
        iconKey: 'ac_unit',
        productCount: 27,
        isPrimary: true,
      ),
      Category(
        id: 'small_appliances',
        name: 'Small Appliances',
        group: 'Major Appliances',
        image: 'https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?w=500&auto=format&fit=crop&q=80',
        iconKey: 'blender',
        productCount: 64,
        isPrimary: true,
      ),

      // Secondary Group 1: Electronics
      Category(
        id: 'tv_electronics',
        name: 'TV & Electronics',
        group: 'Electronics',
        image: 'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=500&auto=format&fit=crop&q=80',
        iconKey: 'tv',
        productCount: 55,
        isPrimary: false,
      ),
      Category(
        id: 'audio_headphones',
        name: 'Audio & Headphones',
        group: 'Electronics',
        image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&auto=format&fit=crop&q=80',
        iconKey: 'headphones',
        productCount: 48,
        isPrimary: false,
      ),
      Category(
        id: 'cameras',
        name: 'Cameras',
        group: 'Electronics',
        image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500&auto=format&fit=crop&q=80',
        iconKey: 'photo_camera',
        productCount: 22,
        isPrimary: false,
      ),

      // Secondary Group 2: Home Essentials
      Category(
        id: 'vacuum_cleaners',
        name: 'Vacuum Cleaners',
        group: 'Home Essentials',
        image: 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=500&auto=format&fit=crop&q=80',
        iconKey: 'cleaning_services',
        productCount: 29,
        isPrimary: false,
      ),
      Category(
        id: 'kitchen_appliances',
        name: 'Kitchen Appliances',
        group: 'Home Essentials',
        image: 'https://images.unsplash.com/photo-1588854337236-6889d631faa8?w=500&auto=format&fit=crop&q=80',
        iconKey: 'soup_kitchen',
        productCount: 73,
        isPrimary: false,
      ),
      Category(
        id: 'cookware_bakeware',
        name: 'Cookware & Bakeware',
        group: 'Home Essentials',
        image: 'https://images.unsplash.com/photo-1584990347449-397f26f21ba9?w=500&auto=format&fit=crop&q=80',
        iconKey: 'outdoor_grill',
        productCount: 45,
        isPrimary: false,
      ),

      // Secondary Group 3: Home & Living
      Category(
        id: 'fans_heaters',
        name: 'Fans & Heaters',
        group: 'Home & Living',
        image: 'https://images.unsplash.com/photo-1618941716939-553df3c6c278?w=500&auto=format&fit=crop&q=80',
        iconKey: 'mode_fan',
        productCount: 34,
        isPrimary: false,
      ),
      Category(
        id: 'lighting',
        name: 'Lighting',
        group: 'Home & Living',
        image: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500&auto=format&fit=crop&q=80',
        iconKey: 'lightbulb',
        productCount: 50,
        isPrimary: false,
      ),
      Category(
        id: 'home_supplies',
        name: 'Home Supplies',
        group: 'Home & Living',
        image: 'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=500&auto=format&fit=crop&q=80',
        iconKey: 'shopping_basket',
        productCount: 62,
        isPrimary: false,
      ),
    ];
  }

  static List<Product> getProducts() {
    return const [
      // 1. Samsung Double Door Refrigerator (Featured in details, cart, compare, wishlist)
      Product(
        id: 'p_fridge_samsung_600',
        name: 'Samsung Double Door Refrigerator',
        brand: 'Samsung',
        categoryId: 'refrigerators',
        categoryName: 'Refrigerators',
        price: 599.0,
        originalPrice: 749.0,
        rating: 4.6,
        reviewCount: 1250,
        inStock: true,
        stockCount: 18,
        description:
            'Spacious and energy-efficient refrigerator with advanced cooling technology. Features Twin Cooling Plus system, digital inverter compressor, and multi-flow air circulation for maximum freshness.',
        images: [
          'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1590794056226-79ef3a8147e1?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'No Frost', subtitle: 'Automatic defrost', iconKey: 'snowflake'),
          ProductFeature(title: 'Energy Saving', subtitle: 'Inverter tech', iconKey: 'bolt'),
          ProductFeature(title: '2 Years Warranty', subtitle: 'Full coverage', iconKey: 'shield'),
          ProductFeature(title: '600L Capacity', subtitle: 'Spacious storage', iconKey: 'box'),
        ],
        specifications: {
          'Brand': 'Samsung',
          'Model Number': 'RT60K7058SL',
          'Color': 'Silver Inox',
          'Capacity': '600 L',
          'Energy Efficiency': 'A++',
          'Dimensions': '70 x 72 x 180 cm',
          'Weight': '86 kg',
          'Cooling Type': 'Twin Cooling Plus & No Frost',
          'Noise Level': '39 dB',
          'Warranty': '2 Years on appliance, 10 Years on Digital Inverter',
        },
        deliveryInfo: {
          'Shipping': 'Free Standard Delivery (2-3 business days)',
          'Express Delivery': 'Next-day delivery available at checkout',
          'Returns': '14-Day Free Returns if unopened or defective',
          'Installation': 'Optional professional unboxing & setup for \$25',
        },
        isFeatured: true,
        isSpecialOffer: true,
        energyRating: 'A++',
        capacity: '600 L',
        dimensions: '70 x 72 x 180 cm',
        warranty: '2 Years',
        hasNoFrost: true,
        colors: ['Silver Inox', 'Black Steel', 'Pearl White'],
      ),

      // 2. LG Front Load Washing Machine
      Product(
        id: 'p_washer_lg_9kg',
        name: 'LG Front Load Washing Machine',
        brand: 'LG',
        categoryId: 'washing_machines',
        categoryName: 'Washing Machines',
        price: 449.0,
        originalPrice: 529.0,
        rating: 4.7,
        reviewCount: 980,
        inStock: true,
        stockCount: 12,
        description:
            'AI DD Intelligent care with 18% more fabric protection. TurboWash 360 cleans thoroughly in 39 minutes with Steam+ hygiene technology that eliminates 99.9% of allergens.',
        images: [
          'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1545173168-9f1947eebb7f?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'Steam+', subtitle: 'Anti-allergy', iconKey: 'cloud'),
          ProductFeature(title: 'AI Inverter DD', subtitle: 'Smart motion', iconKey: 'bolt'),
          ProductFeature(title: '2 Years Warranty', subtitle: 'Full care', iconKey: 'shield'),
          ProductFeature(title: '9.0 kg Load', subtitle: 'Family capacity', iconKey: 'box'),
        ],
        specifications: {
          'Brand': 'LG',
          'Model': 'F4V909WTS',
          'Load Capacity': '9.0 kg',
          'Max Spin Speed': '1400 RPM',
          'Energy Efficiency': 'A+++',
          'Dimensions': '60 x 56.5 x 85 cm',
          'Motor': 'Inverter Direct Drive',
          'Warranty': '2 Years complete, 10 Years motor',
        },
        deliveryInfo: {
          'Shipping': 'Standard delivery in 2 business days',
          'Returns': '14-Day Free Returns policy',
          'Installation': 'Plumbing connection available',
        },
        isFeatured: true,
        isSpecialOffer: true,
        energyRating: 'A+++',
        capacity: '9 kg',
        dimensions: '60 x 56.5 x 85 cm',
        warranty: '2 Years',
        hasNoFrost: false,
      ),

      // 3. Samsung Microwave Oven
      Product(
        id: 'p_micro_samsung_32',
        name: 'Samsung Microwave Oven',
        brand: 'Samsung',
        categoryId: 'cookers_ovens',
        categoryName: 'Cookers & Ovens',
        price: 129.0,
        originalPrice: 149.0,
        rating: 4.6,
        reviewCount: 620,
        inStock: true,
        stockCount: 25,
        description:
            'Triple distribution system delivers evenly cooked meals every time. Ceramic enamel interior is scratch resistant and 99.9% anti-bacterial.',
        images: [
          'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'Ceramic Enamel', subtitle: 'Anti-scratch', iconKey: 'shield'),
          ProductFeature(title: 'Eco Mode', subtitle: 'Low standby power', iconKey: 'bolt'),
          ProductFeature(title: 'Quick Defrost', subtitle: '5 food programs', iconKey: 'snowflake'),
          ProductFeature(title: '32L Capacity', subtitle: 'Spacious interior', iconKey: 'box'),
        ],
        specifications: {
          'Brand': 'Samsung',
          'Model': 'MS32J5133AM',
          'Output Power': '1000 W',
          'Capacity': '32 L',
          'Turntable Size': '31.8 cm',
          'Dimensions': '51.7 x 29.7 x 38.4 cm',
          'Warranty': '1 Year Warranty',
        },
        deliveryInfo: {
          'Shipping': 'Free delivery with prime',
          'Returns': '14-Day Returns',
        },
        isFeatured: true,
        isSpecialOffer: false,
        energyRating: 'A+',
        capacity: '32 L',
        dimensions: '51.7 x 29.7 x 38.4 cm',
        warranty: '1 Year',
        hasNoFrost: false,
      ),

      // 4. Gas Cooker 5 Burners
      Product(
        id: 'p_cooker_gas_5',
        name: 'Gas Cooker 5 Burners',
        brand: 'Bosch',
        categoryId: 'cookers_ovens',
        categoryName: 'Cookers & Ovens',
        price: 349.0,
        originalPrice: 539.0,
        rating: 4.8,
        reviewCount: 410,
        inStock: true,
        stockCount: 8,
        description:
            'Premium 90 cm gas range cooker with heavy-duty cast iron pan supports, high-speed central wok burner, safety auto-flame cutoff, and electric rotisserie grill.',
        images: [
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'Full Safety', subtitle: 'Flame-failure device', iconKey: 'shield'),
          ProductFeature(title: 'Wok Burner', subtitle: '3.5kW high heat', iconKey: 'flame'),
          ProductFeature(title: 'Rotisserie', subtitle: 'Electric turnspit', iconKey: 'microwave'),
          ProductFeature(title: 'Cast Iron', subtitle: 'Durable supports', iconKey: 'box'),
        ],
        specifications: {
          'Brand': 'Bosch',
          'Size': '90 x 60 cm',
          'Burners': '5 Gas burners',
          'Oven Capacity': '105 L',
          'Grill': 'Gas grill with thermostat',
          'Warranty': '3 Years Warranty',
        },
        deliveryInfo: {
          'Shipping': 'Heavy freight delivery within 3 days',
          'Installation': 'Gas line connection available',
        },
        isFeatured: true,
        isSpecialOffer: true,
        energyRating: 'A',
        capacity: '105 L Oven',
        dimensions: '90 x 60 x 85 cm',
        warranty: '3 Years',
        hasNoFrost: false,
      ),

      // 5. Electric Water Heater 50L
      Product(
        id: 'p_heater_ariston_50',
        name: 'Electric Water Heater 50L',
        brand: 'Ariston',
        categoryId: 'water_heaters',
        categoryName: 'Water Heaters',
        price: 139.0,
        originalPrice: 199.0,
        rating: 4.5,
        reviewCount: 320,
        inStock: true,
        stockCount: 15,
        description:
            'Italian titanium enamel coated electric water heater. Fast recovery heating element with Eco Evo smart temperature management and double safety thermostat.',
        images: [
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'Titanium Enamel', subtitle: 'Corrosion-proof', iconKey: 'shield'),
          ProductFeature(title: 'Eco Evo', subtitle: '14% energy savings', iconKey: 'bolt'),
          ProductFeature(title: 'Fast Heating', subtitle: '1500W copper element', iconKey: 'flame'),
          ProductFeature(title: '50L Storage', subtitle: '2-3 persons', iconKey: 'box'),
        ],
        specifications: {
          'Brand': 'Ariston',
          'Capacity': '50 L',
          'Power': '1500 W',
          'Voltage': '220-240 V',
          'Max Pressure': '8 Bar',
          'Warranty': '5 Years tank warranty',
        },
        deliveryInfo: {
          'Shipping': 'Fast delivery within 2 days',
          'Returns': '14 days return policy',
        },
        isFeatured: true,
        isSpecialOffer: true,
        energyRating: 'B',
        capacity: '50 L',
        dimensions: '45 x 48 x 55 cm',
        warranty: '5 Years',
        hasNoFrost: false,
      ),

      // 6. Daikin Air Conditioner 1.5 HP Inverter
      Product(
        id: 'p_ac_daikin_15',
        name: 'Daikin Air Conditioner',
        brand: 'Daikin',
        categoryId: 'air_conditioners',
        categoryName: 'Air Conditioners',
        price: 699.0,
        originalPrice: 799.0,
        rating: 4.5,
        reviewCount: 740,
        inStock: true,
        stockCount: 10,
        description:
            'Smart Inverter split air conditioner with Turbo Cool and Titanium Apatite deodorizing air purifying filter. Silent operation with 19 dBA quiet mode.',
        images: [
          'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'Inverter Tech', subtitle: 'Up to 60% saving', iconKey: 'bolt'),
          ProductFeature(title: 'Ultra Quiet', subtitle: '19 dBA indoor unit', iconKey: 'mode_fan'),
          ProductFeature(title: 'Air Purifying', subtitle: 'Titanium filter', iconKey: 'shield'),
          ProductFeature(title: '1.5 HP Cooling', subtitle: 'For up to 18 m²', iconKey: 'ac_unit'),
        ],
        specifications: {
          'Brand': 'Daikin',
          'Capacity': '1.5 HP (12,000 BTU)',
          'Refrigerant': 'R-32 Eco friendly',
          'Warranty': '5 Years Compressor',
        },
        deliveryInfo: {
          'Shipping': 'Free doorstep delivery',
          'Installation': 'Standard split mounting available for \$30',
        },
        isFeatured: true,
        isSpecialOffer: false,
        energyRating: 'A+++',
        capacity: '1.5 HP (12,000 BTU)',
        dimensions: '80 x 28 x 20 cm',
        warranty: '5 Years',
        hasNoFrost: false,
      ),

      // 7. Smart 4K TV 55 Inch
      Product(
        id: 'p_tv_smart_55',
        name: 'Smart 4K TV 55"',
        brand: 'Samsung',
        categoryId: 'tv_electronics',
        categoryName: 'TV & Electronics',
        price: 499.0,
        originalPrice: 699.0,
        rating: 4.8,
        reviewCount: 1120,
        inStock: true,
        stockCount: 14,
        description:
            'Crystal UHD 4K Processor with HDR10+, bezel-less slim design, motion Xcelerator, and built-in voice assistants with smart hub streaming apps.',
        images: [
          'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: '4K Crystal UHD', subtitle: 'Vivid color engine', iconKey: 'tv'),
          ProductFeature(title: 'HDR10+', subtitle: 'Dynamic contrast', iconKey: 'lightbulb'),
          ProductFeature(title: 'Smart Hub', subtitle: 'Netflix, YouTube & more', iconKey: 'bolt'),
          ProductFeature(title: '55 Inch Display', subtitle: 'Immersive screen', iconKey: 'box'),
        ],
        specifications: {
          'Brand': 'Samsung',
          'Screen Size': '55 Inch',
          'Resolution': '3840 x 2160 (4K UHD)',
          'Refresh Rate': '60 Hz',
          'HDMI Ports': '3',
          'Warranty': '2 Years Official',
        },
        deliveryInfo: {
          'Shipping': 'Secure handling delivery',
          'Returns': '14 days return warranty',
        },
        isFeatured: true,
        isSpecialOffer: true,
        energyRating: 'A+',
        capacity: '55 Inch',
        dimensions: '123 x 71 x 6 cm',
        warranty: '2 Years',
        hasNoFrost: false,
      ),

      // 8. LG Refrigerator (For Side-by-Side Comparison)
      Product(
        id: 'p_fridge_lg_620',
        name: 'LG Refrigerator',
        brand: 'LG',
        categoryId: 'refrigerators',
        categoryName: 'Refrigerators',
        price: 629.0,
        originalPrice: 799.0,
        rating: 4.7,
        reviewCount: 840,
        inStock: true,
        stockCount: 9,
        description:
            'DoorCooling+ and Linear Inverter compressor keep groceries crisper and drinks chilled faster. Features Hygiene Fresh+ 5-step air deodorizer.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'No Frost', subtitle: 'Multi air flow', iconKey: 'snowflake'),
          ProductFeature(title: 'Linear Inverter', subtitle: 'Smart diagnosis', iconKey: 'bolt'),
          ProductFeature(title: '2 Years Warranty', subtitle: '10 yr motor', iconKey: 'shield'),
          ProductFeature(title: '620L Capacity', subtitle: 'Wide storage', iconKey: 'box'),
        ],
        specifications: {
          'Brand': 'LG',
          'Capacity': '620 L',
          'Energy Efficiency': 'A++',
          'Dimensions': '72 x 74 x 182 cm',
          'No Frost': 'Yes (Total No Frost)',
          'Warranty': '2 Years',
        },
        deliveryInfo: {
          'Shipping': 'Free delivery within 3 days',
        },
        isFeatured: false,
        isSpecialOffer: false,
        energyRating: 'A++',
        capacity: '620 L',
        dimensions: '72 x 74 x 182 cm',
        warranty: '2 Years',
        hasNoFrost: true,
      ),

      // 9. Haier Refrigerator (Similar Product)
      Product(
        id: 'p_fridge_haier_550',
        name: 'Haier Refrigerator',
        brand: 'Haier',
        categoryId: 'refrigerators',
        categoryName: 'Refrigerators',
        price: 549.0,
        originalPrice: 659.0,
        rating: 4.4,
        reviewCount: 290,
        inStock: true,
        stockCount: 14,
        description:
            'Twin inverter technology with 360 air circulation and anti-bacterial metal interior backing for uniform cooling.',
        images: [
          'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'No Frost', subtitle: 'Anti-icing', iconKey: 'snowflake'),
          ProductFeature(title: 'Twin Inverter', subtitle: 'Quiet & durable', iconKey: 'bolt'),
        ],
        energyRating: 'A+',
        capacity: '550 L',
        dimensions: '68 x 70 x 175 cm',
        warranty: '2 Years',
        hasNoFrost: true,
      ),

      // 10. Toshiba Refrigerator (Similar Product)
      Product(
        id: 'p_fridge_toshiba_580',
        name: 'Toshiba Refrigerator',
        brand: 'Toshiba',
        categoryId: 'refrigerators',
        categoryName: 'Refrigerators',
        price: 569.0,
        originalPrice: 699.0,
        rating: 4.6,
        reviewCount: 380,
        inStock: true,
        stockCount: 11,
        description:
            'Origin Inverter system with dual radar sensors and PureBio anti-odor catalyst for fresh food preservation.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=800&auto=format&fit=crop&q=80',
        ],
        energyRating: 'A++',
        capacity: '580 L',
        dimensions: '70 x 71 x 178 cm',
        warranty: '2 Years',
        hasNoFrost: true,
      ),

      // 11. Beko Refrigerator (Similar Product)
      Product(
        id: 'p_fridge_beko_600',
        name: 'Beko Refrigerator',
        brand: 'Beko',
        categoryId: 'refrigerators',
        categoryName: 'Refrigerators',
        price: 579.0,
        originalPrice: 710.0,
        rating: 4.5,
        reviewCount: 420,
        inStock: true,
        stockCount: 7,
        description:
            'HarvestFresh 3-color light technology preserves vitamins in vegetables. NeoFrost dual cooling prevents odors mixing.',
        images: [
          'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=800&auto=format&fit=crop&q=80',
        ],
        energyRating: 'A++',
        capacity: '600 L',
        dimensions: '70 x 72 x 180 cm',
        warranty: '2 Years',
        hasNoFrost: true,
      ),

      // 12. Wireless Noise-Canceling Headphones
      Product(
        id: 'p_audio_sony_wh',
        name: 'Sony Wireless ANC Headphones',
        brand: 'Sony',
        categoryId: 'audio_headphones',
        categoryName: 'Audio & Headphones',
        price: 199.0,
        originalPrice: 279.0,
        rating: 4.9,
        reviewCount: 1650,
        inStock: true,
        stockCount: 30,
        description:
            'Industry-leading active noise canceling with dual noise sensor technology. Up to 30-hour battery life with quick charging (10 min charge for 5 hours of playback).',
        images: [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'Active ANC', subtitle: 'Noise canceling', iconKey: 'headphones'),
          ProductFeature(title: '30h Battery', subtitle: 'Quick charging', iconKey: 'bolt'),
        ],
        energyRating: 'A+++',
        capacity: '30h Playtime',
        dimensions: 'Compact Foldable',
        warranty: '1 Year',
        hasNoFrost: false,
      ),

      // 13. Kitchen Stand Mixer
      Product(
        id: 'p_mixer_stand_pro',
        name: 'Kitchen Stand Mixer 1000W',
        brand: 'Bosch',
        categoryId: 'small_appliances',
        categoryName: 'Small Appliances',
        price: 189.0,
        originalPrice: 249.0,
        rating: 4.7,
        reviewCount: 512,
        inStock: true,
        stockCount: 16,
        description:
            'Powerful 1000W motor with 3D PlanetaryMixing for swift and thorough mixing of all ingredients. 3.9L stainless steel bowl.',
        images: [
          'https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: '1000W Motor', subtitle: 'Planetary mixing', iconKey: 'bolt'),
          ProductFeature(title: '3.9L Bowl', subtitle: 'Stainless steel', iconKey: 'box'),
        ],
        energyRating: 'A',
        capacity: '3.9 L',
        dimensions: '28 x 27 x 28 cm',
        warranty: '2 Years',
        hasNoFrost: false,
      ),

      // 14. Cordless Vacuum Cleaner
      Product(
        id: 'p_vacuum_cordless',
        name: 'Dyson V12 Detect Slim Cordless Vacuum',
        brand: 'Dyson',
        categoryId: 'vacuum_cleaners',
        categoryName: 'Vacuum Cleaners',
        price: 399.0,
        originalPrice: 499.0,
        rating: 4.8,
        reviewCount: 780,
        inStock: true,
        stockCount: 10,
        description:
            'Laser reveals invisible dust on hard floors. Piezo sensor continuously sizes and counts dust particles. Up to 60 minutes of run time.',
        images: [
          'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&auto=format&fit=crop&q=80',
        ],
        features: [
          ProductFeature(title: 'Laser Slim', subtitle: 'Detects microscopic dust', iconKey: 'lightbulb'),
          ProductFeature(title: '60 Min Runtime', subtitle: 'Click-in battery', iconKey: 'bolt'),
        ],
        energyRating: 'A++',
        capacity: '0.35 L Bin',
        dimensions: '123 x 25 x 25 cm',
        warranty: '2 Years',
        hasNoFrost: false,
      ),
    ];
  }

  static List<Review> getSampleReviews(String productId) {
    return [
      Review(
        id: 'rev_1',
        productId: productId,
        productName: 'Samsung Double Door Refrigerator',
        userName: 'Omar Hassan',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        comment:
            'Amazing cooling efficiency and exceptionally quiet! The freezer space is very generous and vegetables stay crisp for over 10 days. HomePlus delivery team installed it within 15 minutes.',
        isVerifiedPurchase: true,
        helpfulCount: 24,
      ),
      Review(
        id: 'rev_2',
        productId: productId,
        productName: 'Samsung Double Door Refrigerator',
        userName: 'Mona Youssef',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 9)),
        comment:
            'Best refrigerator purchase in years. The silver finish matches our kitchen perfectly and does not pick up fingerprints. No frost build-up whatsoever.',
        isVerifiedPurchase: true,
        helpfulCount: 18,
      ),
      Review(
        id: 'rev_3',
        productId: productId,
        productName: 'Samsung Double Door Refrigerator',
        userName: 'Khaled Nabil',
        rating: 4.0,
        date: DateTime.now().subtract(const Duration(days: 18)),
        comment:
            'Very good appliance overall. Energy consumption is lower than my previous fridge. The only small note is the door shelves could be slightly deeper, but otherwise 10/10.',
        isVerifiedPurchase: true,
        helpfulCount: 7,
      ),
    ];
  }

  static List<Coupon> getSampleCoupons() {
    return [
      Coupon(
        code: 'HOMEPLUS100',
        title: '\$100 Appliance Voucher',
        description: 'Get \$100 off any order exceeding \$500.',
        discountAmount: 100.0,
        minSpend: 500.0,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
      Coupon(
        code: 'SAVE20',
        title: '20% Mega Season Discount',
        description: '20% discount on select major home appliances.',
        discountPercentage: 20.0,
        minSpend: 200.0,
        expiryDate: DateTime.now().add(const Duration(days: 14)),
      ),
      Coupon(
        code: 'FREESHIP',
        title: 'Free Shipping Pass',
        description: 'Enjoy free doorstep express delivery with zero charges.',
        discountAmount: 20.0,
        minSpend: 50.0,
        expiryDate: DateTime.now().add(const Duration(days: 60)),
      ),
      Coupon(
        code: 'WELCOME50',
        title: 'New Customer Welcome',
        description: '\$50 instant reduction for new registered members.',
        discountAmount: 50.0,
        minSpend: 300.0,
        expiryDate: DateTime.now().add(const Duration(days: 45)),
      ),
    ];
  }

  static List<FaqItem> getSampleFaqs() {
    return const [
      FaqItem(
        id: 'faq_1',
        category: 'Orders & Delivery',
        question: 'How long does standard appliance delivery take?',
        answer:
            'Standard delivery takes between 2 to 3 business days within major metropolitan areas. Express next-day delivery is also available at checkout for orders placed before 3:00 PM.',
      ),
      FaqItem(
        id: 'faq_2',
        category: 'Orders & Delivery',
        question: 'Do you offer professional installation for cookers and washers?',
        answer:
            'Yes! You can choose the Professional Installation option at checkout for just \$25. Our certified technicians will safely unbox, level, and connect your appliances with warranty guarantee.',
      ),
      FaqItem(
        id: 'faq_3',
        category: 'Returns & Refunds',
        question: 'What is HomePlus return and exchange policy?',
        answer:
            'We provide a 14-day hassle-free return policy. If you receive an item that is defective, damaged, or does not match specifications, we will collect it and issue a full refund to your original payment method or wallet.',
      ),
      FaqItem(
        id: 'faq_4',
        category: 'Warranty & Services',
        question: 'How do I claim manufacturer warranty?',
        answer:
            'All products sold on HomePlus are 100% genuine and carry full official manufacturer warranties (typically 2 to 5 years). Your digital invoice in My Orders serves as proof of purchase.',
      ),
      FaqItem(
        id: 'faq_5',
        category: 'Payments',
        question: 'What payment options are accepted?',
        answer:
            'We accept Cash on Delivery, Credit/Debit cards (Visa, MasterCard, American Express), Apple Pay, Google Pay, Bank Wire Transfer, and 0% interest monthly installment plans.',
      ),
    ];
  }

  static List<NotificationItem> getSampleNotifications() {
    return [
      NotificationItem(
        id: 'notif_1',
        title: 'Order #HP123456 Preparing',
        message: 'Your Samsung Double Door Refrigerator is being prepared for dispatch.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: 'order',
        actionRoute: '/orders',
      ),
      NotificationItem(
        id: 'notif_2',
        title: 'Weekend Flash Sale is Live!',
        message: 'Save up to 40% on top kitchen appliances and smart TVs this weekend only.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: false,
        type: 'promo',
        actionRoute: '/offers',
      ),
      NotificationItem(
        id: 'notif_3',
        title: 'Delivery Confirmed for Tomorrow',
        message: 'Our driver will deliver your package between 10:00 AM and 2:00 PM.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'delivery',
        actionRoute: '/orders',
      ),
    ];
  }

  static Address getDefaultAddress() {
    return const Address(
      id: 'addr_1',
      recipientName: 'Ahmed Mohamed',
      phone: '+20 100 123 4567',
      city: 'Cairo',
      area: 'Nasr City',
      street: '123 Main Street',
      building: 'Building 14',
      apartment: '4B',
      instructions: 'Please call before arrival. Elevator available on 4th floor.',
      label: 'Home',
      isDefault: true,
    );
  }

  static UserModel getDefaultUser() {
    return UserModel(
      id: 'user_1',
      name: 'Ahmed Mohamed',
      email: 'ahmed@example.com',
      phone: '+20 100 123 4567',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
      addresses: [
        getDefaultAddress(),
        const Address(
          id: 'addr_2',
          recipientName: 'Ahmed Mohamed',
          phone: '+20 100 123 4567',
          city: 'Cairo',
          area: 'New Cairo',
          street: '90th South Street',
          building: 'Tech Park B3',
          apartment: 'Office 201',
          label: 'Work',
          isDefault: false,
        ),
      ],
      walletBalance: 50.0,
      ordersCount: 12,
      wishlistCount: 24,
      rating: 4.6,
      reviewsCount: 15,
      isGuest: false,
    );
  }
}

