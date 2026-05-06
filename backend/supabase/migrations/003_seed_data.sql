-- 003_seed_data.sql
-- Seed data for Medlingo: 15 chapters, 6 lessons each, 2 products

-- ============================================================
-- CHAPTERS
-- ============================================================
INSERT INTO chapters (id, number, title, summary, estimated_minutes, is_premium, accent_color_hex, unlock_rule) VALUES
    ('a0000001-0000-0000-0000-000000000001', 1, 'Word Parts & Foundations', 'Learn prefixes, suffixes, and root words that form the building blocks of medical terminology.', 45, false, '#4A90D9', 'free'),
    ('a0000001-0000-0000-0000-000000000002', 2, 'Body Organization', 'Understand anatomical planes, body cavities, directional terms, and levels of structural organization.', 50, false, '#7B68EE', 'free'),
    ('a0000001-0000-0000-0000-000000000003', 3, 'Integumentary System', 'Explore the skin, hair, nails, and glands that protect the body from the external environment.', 55, false, '#E8A87C', 'sequential'),
    ('a0000001-0000-0000-0000-000000000004', 4, 'Skeletal System', 'Study bones, joints, and connective tissues that provide framework and support.', 60, false, '#F5F5DC', 'sequential'),
    ('a0000001-0000-0000-0000-000000000005', 5, 'Muscular System', 'Discover the terminology of skeletal, smooth, and cardiac muscle tissues.', 55, false, '#DC143C', 'sequential'),
    ('a0000001-0000-0000-0000-000000000006', 6, 'Nervous System', 'Master terms related to the brain, spinal cord, nerves, and neural communication.', 65, true, '#9370DB', 'sequential'),
    ('a0000001-0000-0000-0000-000000000007', 7, 'Special Senses', 'Learn terminology for vision, hearing, taste, smell, and balance.', 50, true, '#20B2AA', 'sequential'),
    ('a0000001-0000-0000-0000-000000000008', 8, 'Endocrine System', 'Understand hormones, glands, and feedback mechanisms that regulate body functions.', 55, true, '#FFD700', 'sequential'),
    ('a0000001-0000-0000-0000-000000000009', 9, 'Cardiovascular System', 'Study the heart, blood vessels, and circulation terminology.', 60, true, '#FF4500', 'sequential'),
    ('a0000001-0000-0000-0000-000000000010', 10, 'Lymphatic & Immunity', 'Explore the lymph system, immune cells, and defense mechanisms.', 55, true, '#32CD32', 'sequential'),
    ('a0000001-0000-0000-0000-000000000011', 11, 'Respiratory System', 'Learn terms for the airways, lungs, and gas exchange processes.', 55, true, '#87CEEB', 'sequential'),
    ('a0000001-0000-0000-0000-000000000012', 12, 'Digestive System', 'Master terminology for the GI tract from mouth to anus and accessory organs.', 60, true, '#D2691E', 'sequential'),
    ('a0000001-0000-0000-0000-000000000013', 13, 'Urinary System', 'Study the kidneys, ureters, bladder, and urethra terminology.', 50, true, '#4682B4', 'sequential'),
    ('a0000001-0000-0000-0000-000000000014', 14, 'Reproductive System', 'Understand male and female reproductive anatomy and related medical terms.', 55, true, '#FF69B4', 'sequential'),
    ('a0000001-0000-0000-0000-000000000015', 15, 'Clinical Applications', 'Apply medical terminology to clinical scenarios, diagnostics, and treatment plans.', 70, true, '#2F4F4F', 'sequential');

-- ============================================================
-- LESSONS (6 per chapter = 90 total)
-- ============================================================

-- Chapter 1: Word Parts & Foundations
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000001', 1, 'Introduction to Word Roots', 'Learn how root words form the core meaning of medical terms.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000001', 2, 'Prefixes That Modify Meaning', 'Discover common prefixes used in medical terminology.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000001', 3, 'Suffixes That Indicate Conditions', 'Study suffixes that describe diseases, procedures, and conditions.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000001', 4, 'Combining Vowels & Forms', 'Understand how combining vowels connect word parts.', 'theory', 7),
    ('a0000001-0000-0000-0000-000000000001', 5, 'Building Medical Terms', 'Practice assembling terms from individual components.', 'practice', 7),
    ('a0000001-0000-0000-0000-000000000001', 6, 'Word Parts Review & Quiz', 'Test your knowledge of word parts foundations.', 'quiz', 7);

-- Chapter 2: Body Organization
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000002', 1, 'Levels of Organization', 'From atoms to organisms: understanding structural hierarchy.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000002', 2, 'Anatomical Position & Planes', 'Learn standard body position and sectional planes.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000002', 3, 'Directional Terms', 'Master superior, inferior, anterior, posterior, and more.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000002', 4, 'Body Cavities & Regions', 'Explore dorsal, ventral cavities and abdominal regions.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000002', 5, 'Organ Systems Overview', 'Brief introduction to the 11 major organ systems.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000002', 6, 'Body Organization Review', 'Comprehensive review of body organization concepts.', 'quiz', 8);

-- Chapter 3: Integumentary System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000003', 1, 'Skin Structure & Layers', 'Epidermis, dermis, and hypodermis terminology.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000003', 2, 'Accessory Structures', 'Hair, nails, sebaceous and sudoriferous glands.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000003', 3, 'Common Skin Conditions', 'Dermatitis, eczema, psoriasis, and related terms.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000003', 4, 'Burns & Wound Healing', 'Classification of burns and stages of tissue repair.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000003', 5, 'Dermatological Procedures', 'Biopsy, debridement, grafting terminology.', 'practice', 9),
    ('a0000001-0000-0000-0000-000000000003', 6, 'Integumentary Review', 'Test your integumentary system knowledge.', 'quiz', 9);

-- Chapter 4: Skeletal System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000004', 1, 'Bone Structure & Classification', 'Long, short, flat, irregular bones and their anatomy.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000004', 2, 'Axial Skeleton', 'Skull, vertebral column, and thoracic cage terminology.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000004', 3, 'Appendicular Skeleton', 'Upper and lower limb bones and girdles.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000004', 4, 'Joints & Articulations', 'Synovial joints, cartilaginous, and fibrous connections.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000004', 5, 'Skeletal Pathology', 'Fractures, osteoporosis, arthritis terminology.', 'practice', 10),
    ('a0000001-0000-0000-0000-000000000004', 6, 'Skeletal System Review', 'Comprehensive skeletal system assessment.', 'quiz', 10);

-- Chapter 5: Muscular System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000005', 1, 'Muscle Tissue Types', 'Skeletal, smooth, and cardiac muscle characteristics.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000005', 2, 'Muscle Anatomy & Naming', 'How muscles are named by location, size, shape, and action.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000005', 3, 'Major Muscle Groups', 'Key muscles of the head, trunk, and extremities.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000005', 4, 'Muscle Movements', 'Flexion, extension, abduction, adduction, and rotation terms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000005', 5, 'Muscular Disorders', 'Myalgia, dystrophy, strain, and spasm terminology.', 'practice', 9),
    ('a0000001-0000-0000-0000-000000000005', 6, 'Muscular System Review', 'Test your muscular system vocabulary.', 'quiz', 9);

-- Chapter 6: Nervous System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000006', 1, 'Neural Tissue & Cells', 'Neurons, neuroglia, and synaptic terminology.', 'theory', 11),
    ('a0000001-0000-0000-0000-000000000006', 2, 'Central Nervous System', 'Brain regions, spinal cord, and meninges terms.', 'theory', 11),
    ('a0000001-0000-0000-0000-000000000006', 3, 'Peripheral Nervous System', 'Cranial nerves, spinal nerves, and plexuses.', 'theory', 11),
    ('a0000001-0000-0000-0000-000000000006', 4, 'Autonomic Nervous System', 'Sympathetic and parasympathetic divisions.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000006', 5, 'Neurological Disorders', 'Epilepsy, stroke, neuropathy, and related terms.', 'practice', 11),
    ('a0000001-0000-0000-0000-000000000006', 6, 'Nervous System Review', 'Comprehensive nervous system assessment.', 'quiz', 11);

-- Chapter 7: Special Senses
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000007', 1, 'The Eye & Vision', 'Anatomy of the eye and visual pathway terminology.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000007', 2, 'The Ear & Hearing', 'Outer, middle, inner ear structures and auditory terms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000007', 3, 'Equilibrium & Balance', 'Vestibular apparatus and balance terminology.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000007', 4, 'Taste & Smell', 'Gustatory and olfactory receptor terminology.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000007', 5, 'Sensory Disorders', 'Cataracts, glaucoma, tinnitus, and anosmia terms.', 'practice', 8),
    ('a0000001-0000-0000-0000-000000000007', 6, 'Special Senses Review', 'Test your knowledge of the special senses.', 'quiz', 9);

-- Chapter 8: Endocrine System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000008', 1, 'Endocrine Glands Overview', 'Major glands and their locations in the body.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000008', 2, 'Hormones & Their Actions', 'Key hormones and their target organs.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000008', 3, 'Feedback Mechanisms', 'Positive and negative feedback loop terminology.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000008', 4, 'Pituitary & Hypothalamus', 'Master gland terminology and control pathways.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000008', 5, 'Endocrine Disorders', 'Diabetes, thyroid disorders, and adrenal conditions.', 'practice', 9),
    ('a0000001-0000-0000-0000-000000000008', 6, 'Endocrine System Review', 'Comprehensive endocrine assessment.', 'quiz', 9);

-- Chapter 9: Cardiovascular System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000009', 1, 'Heart Anatomy', 'Chambers, valves, and layers of the heart.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000009', 2, 'Cardiac Cycle & Conduction', 'Electrical conduction and heartbeat terminology.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000009', 3, 'Blood Vessels', 'Arteries, veins, capillaries, and vascular terms.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000009', 4, 'Blood & Formed Elements', 'RBCs, WBCs, platelets, and plasma terminology.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000009', 5, 'Cardiovascular Pathology', 'MI, CHF, arrhythmias, and hypertension terms.', 'practice', 10),
    ('a0000001-0000-0000-0000-000000000009', 6, 'Cardiovascular Review', 'Test your cardiovascular vocabulary.', 'quiz', 10);

-- Chapter 10: Lymphatic & Immunity
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000010', 1, 'Lymphatic System Anatomy', 'Lymph nodes, vessels, spleen, and thymus.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000010', 2, 'Innate Immunity', 'Physical barriers, phagocytes, and inflammatory terms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000010', 3, 'Adaptive Immunity', 'T-cells, B-cells, antibodies, and memory cells.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000010', 4, 'Immunization & Allergy', 'Vaccine, antigen, allergen terminology.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000010', 5, 'Immune Disorders', 'Autoimmune diseases, HIV/AIDS, and immunodeficiency.', 'practice', 9),
    ('a0000001-0000-0000-0000-000000000010', 6, 'Lymphatic & Immunity Review', 'Comprehensive immune system assessment.', 'quiz', 9);

-- Chapter 11: Respiratory System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000011', 1, 'Upper Respiratory Tract', 'Nose, pharynx, and larynx terminology.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000011', 2, 'Lower Respiratory Tract', 'Trachea, bronchi, and lung anatomy terms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000011', 3, 'Gas Exchange & Ventilation', 'Alveoli, diffusion, and respiratory mechanics.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000011', 4, 'Breathing Regulation', 'Respiratory centers and control mechanisms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000011', 5, 'Respiratory Disorders', 'Asthma, COPD, pneumonia, and TB terminology.', 'practice', 9),
    ('a0000001-0000-0000-0000-000000000011', 6, 'Respiratory System Review', 'Test your respiratory vocabulary.', 'quiz', 9);

-- Chapter 12: Digestive System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000012', 1, 'Oral Cavity & Esophagus', 'Teeth, tongue, salivary glands, and swallowing terms.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000012', 2, 'Stomach & Small Intestine', 'Gastric regions, duodenum, jejunum, ileum.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000012', 3, 'Large Intestine & Rectum', 'Colon segments, cecum, appendix terminology.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000012', 4, 'Accessory Organs', 'Liver, gallbladder, and pancreas terminology.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000012', 5, 'GI Pathology', 'GERD, ulcers, IBD, and hepatitis terms.', 'practice', 10),
    ('a0000001-0000-0000-0000-000000000012', 6, 'Digestive System Review', 'Comprehensive GI system assessment.', 'quiz', 10);

-- Chapter 13: Urinary System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000013', 1, 'Kidney Anatomy', 'Cortex, medulla, nephron, and renal pelvis terms.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000013', 2, 'Urine Formation', 'Filtration, reabsorption, and secretion terminology.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000013', 3, 'Ureters, Bladder & Urethra', 'Transport and storage structure terms.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000013', 4, 'Fluid & Electrolyte Balance', 'Osmolality, pH, and electrolyte terminology.', 'theory', 8),
    ('a0000001-0000-0000-0000-000000000013', 5, 'Urinary Disorders', 'UTI, nephrolithiasis, renal failure terms.', 'practice', 8),
    ('a0000001-0000-0000-0000-000000000013', 6, 'Urinary System Review', 'Test your urinary system knowledge.', 'quiz', 9);

-- Chapter 14: Reproductive System
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000014', 1, 'Male Reproductive Anatomy', 'Testes, epididymis, vas deferens, and prostate terms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000014', 2, 'Female Reproductive Anatomy', 'Ovaries, uterus, fallopian tubes, and vagina terms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000014', 3, 'Menstrual Cycle & Hormones', 'Estrogen, progesterone, and cycle phase terminology.', 'theory', 10),
    ('a0000001-0000-0000-0000-000000000014', 4, 'Pregnancy & Development', 'Gestation, embryology, and obstetric terms.', 'theory', 9),
    ('a0000001-0000-0000-0000-000000000014', 5, 'Reproductive Disorders', 'Infertility, STIs, and neoplasm terminology.', 'practice', 9),
    ('a0000001-0000-0000-0000-000000000014', 6, 'Reproductive System Review', 'Comprehensive reproductive assessment.', 'quiz', 9);

-- Chapter 15: Clinical Applications
INSERT INTO lessons (chapter_id, order_index, title, content, type, estimated_minutes) VALUES
    ('a0000001-0000-0000-0000-000000000015', 1, 'Medical Records & Documentation', 'SOAP notes, abbreviations, and charting terms.', 'theory', 12),
    ('a0000001-0000-0000-0000-000000000015', 2, 'Diagnostic Procedures', 'Imaging, lab tests, and diagnostic terminology.', 'theory', 12),
    ('a0000001-0000-0000-0000-000000000015', 3, 'Pharmacology Basics', 'Drug classification, routes, and dosage terms.', 'theory', 12),
    ('a0000001-0000-0000-0000-000000000015', 4, 'Surgical Terminology', 'Common surgical procedures and instrument names.', 'theory', 11),
    ('a0000001-0000-0000-0000-000000000015', 5, 'Case Studies', 'Apply terminology to real clinical scenarios.', 'practice', 12),
    ('a0000001-0000-0000-0000-000000000015', 6, 'Final Comprehensive Review', 'Complete course assessment covering all systems.', 'quiz', 11);

-- ============================================================
-- PRODUCTS
-- ============================================================
INSERT INTO products (id, name, description, type, price_cents, features) VALUES
    ('premium_monthly', 'Medlingo Premium Monthly', 'Full access to all chapters, exercises, and tutor sessions with monthly billing.', 'subscription', 999, ARRAY['All 15 chapters unlocked', 'Unlimited exercises', 'Tutor session booking', 'Progress analytics', 'Ad-free experience']),
    ('premium_yearly', 'Medlingo Premium Yearly', 'Full access to all chapters, exercises, and tutor sessions with annual billing (save 40%).', 'subscription', 5999, ARRAY['All 15 chapters unlocked', 'Unlimited exercises', 'Tutor session booking', 'Progress analytics', 'Ad-free experience', 'Priority tutor matching']);
